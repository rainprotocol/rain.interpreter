use crate::error::ForkCallError;
use alloy::primitives::{Address, BlockNumber, U256};
use alloy::sol_types::SolCall;
use foundry_evm::{
    backend::{Backend, DatabaseExt, LocalForkId},
    executors::{Executor, ExecutorBuilder, RawCallResult},
    fork::{CreateFork, ForkId, MultiFork},
    opts::EvmOpts,
};
use rain_error_decoding::AbiDecodedErrorType;
use revm::{
    interpreter::InstructionResult,
    primitives::{Address as Addr, Bytes, Env, HashSet, SpecId},
    JournaledState,
};
use std::{any::type_name, collections::HashMap};

/// Forker is thin wrapper around foundry for easily forking multiple evm
/// networks with in-memory cache that provides easy to use read/write
/// functionalities.
#[derive(Clone)]
pub struct Forker {
    pub executor: Executor,
    forks: HashMap<ForkId, (LocalForkId, SpecId, BlockNumber)>,
}

pub struct ForkTypedReturn<C: SolCall> {
    pub raw: RawCallResult,
    pub typed_return: C::Return,
}

#[derive(Debug, Clone)]
pub struct NewForkedEvm {
    pub fork_url: String,
    pub fork_block_number: Option<BlockNumber>,
}

impl Default for Forker {
    fn default() -> Self {
        Self::new()
    }
}
impl Forker {
    /// Creates a new empty instance of `Forker`.
    pub fn new() -> Forker {
        let db = Backend::new(MultiFork::new().0, None);
        let builder = ExecutorBuilder::default().inspectors(|stack| stack.trace(true).debug(false));
        Self {
            executor: builder.build(Env::default(), db),
            forks: HashMap::new(),
        }
    }

    /// Creates a new instance of `Forker` with the specified fork URL and optional fork block number.
    ///
    /// # Arguments
    ///
    /// * `fork_url` - The URL of the fork to connect to.
    /// * `fork_block_number` - Optional fork block number to start from.
    /// * `env` - Optional fork environment.
    /// * `gas_limit` - Optional fork gas limit.
    ///
    /// # Returns
    ///
    /// A new instance of `Forker`.
    /// # Examples
    ///
    /// ```
    /// use rain_interpreter_eval::fork::{Forker, NewForkedEvm};
    ///
    /// let fork_url = "https://example.com/fork".to_owned();
    /// let fork_block_number = Some(12345u64);
    /// let args = NewForkedEvm { fork_url, fork_block_number };
    ///
    /// let forker = Forker::new_with_fork(args, None, None);
    /// ```
    pub async fn new_with_fork(
        args: NewForkedEvm,
        env: Option<Env>,
        gas_limit: Option<u64>,
    ) -> Result<Forker, ForkCallError> {
        let NewForkedEvm {
            fork_url,
            fork_block_number,
        } = args;
        let fork_id = ForkId::new(&fork_url, fork_block_number);
        let evm_opts = EvmOpts {
            fork_url: Some(fork_url.to_string()),
            fork_block_number,
            env: foundry_evm::opts::Env {
                chain_id: None,
                code_size_limit: None,
                gas_limit: u64::MAX,
                ..Default::default()
            },
            memory_limit: u64::MAX,
            ..Default::default()
        };

        let create_fork = CreateFork {
            url: fork_url.to_string(),
            enable_caching: true,
            env: evm_opts.fork_evm_env(fork_url).await?.0,
            evm_opts,
        };
        let block_number = if let Some(v) = fork_block_number {
            BlockNumber::from(v)
        } else {
            create_fork.env.block.number.try_into()?
        };

        let db = Backend::spawn(Some(create_fork.clone()));

        let builder = if let Some(gas) = gas_limit {
            ExecutorBuilder::default()
                .gas_limit(gas)
                .inspectors(|stack| stack.trace(true).debug(false))
        } else {
            ExecutorBuilder::default().inspectors(|stack| stack.trace(true).debug(false))
        };

        let mut forks_map = HashMap::new();
        forks_map.insert(fork_id, (U256::from(0), SpecId::LATEST, block_number));
        Ok(Self {
            executor: builder.build(env.unwrap_or(create_fork.env.clone()), db),
            forks: forks_map,
        })
    }

    /// Adds new fork and sets it as active or if the fork already exists, selects it as active.
    /// Does nothing if the fork is already the active fork.
    pub async fn add_or_select(
        &mut self,
        args: NewForkedEvm,
        env: Option<Env>,
    ) -> Result<(), ForkCallError> {
        if self.forks.is_empty() {
            let forker = Self::new_with_fork(args, env, None).await?;
            self.executor = forker.executor;
            self.forks = forker.forks;
            return Ok(());
        }
        let NewForkedEvm {
            fork_url,
            fork_block_number,
        } = args;
        let fork_id = ForkId::new(&fork_url, fork_block_number);
        if let Some((local_fork_id, spec_id, _)) = self.forks.get(&fork_id) {
            if self.executor.backend().is_active_fork(*local_fork_id) {
                Ok(())
            } else {
                let mut journaled_state = JournaledState::new(*spec_id, HashSet::new());
                self.executor
                    .backend_mut()
                    .select_fork(
                        *local_fork_id,
                        &mut env.unwrap_or_default(),
                        &mut journaled_state,
                    )
                    .map(|_| ())
                    .map_err(|e| ForkCallError::ExecutorError(e.to_string()))
            }
        } else {
            let evm_opts = EvmOpts {
                fork_url: Some(fork_url.to_string()),
                fork_block_number,
                env: foundry_evm::opts::Env {
                    chain_id: None,
                    code_size_limit: None,
                    gas_limit: u64::MAX,
                    ..Default::default()
                },
                memory_limit: u64::MAX,
                ..Default::default()
            };
            let create_fork = CreateFork {
                url: fork_url.to_string(),
                enable_caching: true,
                env: evm_opts.fork_evm_env(fork_url).await.unwrap().0,
                evm_opts,
            };
            let block_number = if let Some(v) = fork_block_number {
                BlockNumber::from(v)
            } else {
                create_fork.env.block.number.try_into()?
            };
            let mut journaled_state = JournaledState::new(SpecId::LATEST, HashSet::new());
            self.forks.insert(
                fork_id,
                (U256::from(self.forks.len()), SpecId::LATEST, block_number),
            );
            let default_env = create_fork.env.clone();
            self.executor
                .backend_mut()
                .create_select_fork(
                    create_fork,
                    &mut env.unwrap_or(default_env),
                    &mut journaled_state,
                )
                .map(|_| ())
                .map_err(|e| ForkCallError::ExecutorError(e.to_string()))
        }
    }

    /// Calls the forked EVM without commiting to state using alloy typed arguments.
    /// # Arguments
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `call` - The call to make.
    /// # Returns
    /// A result containing the raw call result and the typed return.
    pub async fn alloy_call<T: SolCall>(
        &self,
        from_address: Address,
        to_address: Address,
        call: T,
        decode_error: bool,
    ) -> Result<ForkTypedReturn<T>, ForkCallError> {
        let raw = self.call(
            from_address.as_slice(),
            to_address.as_slice(),
            &call.abi_encode(),
        )?;

        if decode_error && raw.exit_reason == InstructionResult::Revert {
            // decode result bytes to error selectors if it was a revert
            return Err(ForkCallError::AbiDecodedError(
                AbiDecodedErrorType::selector_registry_abi_decode(&raw.result).await?,
            ));
        }

        if !raw.exit_reason.is_ok() {
            return Err(ForkCallError::Failed(raw));
        }

        let typed_return = T::abi_decode_returns(&raw.result.0, true).map_err(|e| {
            ForkCallError::TypedError(format!(
                "Call:{:?} Error:{:?} Raw:{:?}",
                type_name::<T>(),
                e,
                raw
            ))
        })?;
        Ok(ForkTypedReturn { raw, typed_return })
    }

    /// Writes to the forked EVM using alloy typed arguments.
    /// # Arguments
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `call` - The call to make.
    /// * `value` - The value to send with the call.
    /// # Returns
    /// A result containing the raw call result and the typed return.
    pub async fn alloy_call_committing<T: SolCall>(
        &mut self,
        from_address: Address,
        to_address: Address,
        call: T,
        value: U256,
        decode_error: bool,
    ) -> Result<ForkTypedReturn<T>, ForkCallError> {
        let raw: RawCallResult = self.call_committing(
            from_address.as_slice(),
            to_address.as_slice(),
            &call.abi_encode(),
            value,
        )?;

        if decode_error && raw.exit_reason == InstructionResult::Revert {
            // decode result bytes to error selectors if it was a revert
            return Err(ForkCallError::AbiDecodedError(
                AbiDecodedErrorType::selector_registry_abi_decode(&raw.result).await?,
            ));
        }

        if !raw.exit_reason.is_ok() {
            return Err(ForkCallError::Failed(raw));
        }

        let typed_return = T::abi_decode_returns(&raw.result.0, true).map_err(|e| {
            ForkCallError::TypedError(format!("Call:{:?} Error:{:?}", type_name::<T>(), e))
        })?;
        Ok(ForkTypedReturn { raw, typed_return })
    }

    /// Calls the forked EVM without commiting to state.
    /// # Arguments
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `calldata` - The calldata.
    /// # Returns
    /// A result containing the raw call result.
    pub fn call(
        &self,
        from_address: &[u8],
        to_address: &[u8],
        calldata: &[u8],
    ) -> Result<RawCallResult, ForkCallError> {
        if from_address.len() != 20 || to_address.len() != 20 {
            return Err(ForkCallError::ExecutorError("invalid address!".to_owned()));
        }

        self.executor
            .call_raw(
                Addr::from_slice(from_address),
                Addr::from_slice(to_address),
                Bytes::copy_from_slice(calldata),
                U256::from(0),
            )
            .map_err(|e| ForkCallError::ExecutorError(e.to_string()))
    }

    /// Writes to the forked EVM.
    /// # Arguments
    /// * `from_address` - The address to call from.
    /// * `to_address` - The address to call to.
    /// * `calldata` - The calldata.
    /// * `value` - The value to send with the call.
    /// # Returns
    /// A result containing the raw call result.
    pub fn call_committing(
        &mut self,
        from_address: &[u8],
        to_address: &[u8],
        calldata: &[u8],
        value: U256,
    ) -> Result<RawCallResult, ForkCallError> {
        if from_address.len() != 20 || to_address.len() != 20 {
            return Err(ForkCallError::ExecutorError("invalid address!".to_owned()));
        }

        let result = self
            .executor
            .transact_raw(
                Addr::from_slice(from_address),
                Addr::from_slice(to_address),
                Bytes::copy_from_slice(calldata),
                value,
            )
            .map_err(|e| ForkCallError::ExecutorError(e.to_string()));

        // remove to_address from persisted accounts
        self.executor
            .backend_mut()
            .remove_persistent_account(&Addr::from_slice(to_address));

        result
    }

    /// resets the active fork to a given block number or to original fork block number if not provided
    pub fn roll_fork(
        &mut self,
        block_number: Option<BlockNumber>,
        env: Option<Env>,
    ) -> Result<(), ForkCallError> {
        let active_fork_local_id = self
            .executor
            .backend()
            .active_fork_id()
            .ok_or(ForkCallError::ExecutorError("no active fork!".to_owned()))?;
        let mut org_block_number = None;
        let mut spec_id = SpecId::LATEST;
        #[allow(clippy::for_kv_map)]
        for (_fork_id, (local_id, sid, bnumber)) in &self.forks {
            if *local_id == active_fork_local_id {
                spec_id = *sid;
                org_block_number = Some(*bnumber);
                break;
            }
        }
        if org_block_number.is_none() {
            return Err(ForkCallError::ExecutorError("no active fork!".to_owned()));
        }
        let block_number = block_number
            .map(BlockNumber::from)
            .unwrap_or(org_block_number.unwrap());

        self.executor.env_mut().block.number = U256::from(block_number);

        self.executor
            .backend_mut()
            .roll_fork(
                Some(active_fork_local_id),
                block_number,
                &mut env.unwrap_or_default(),
                &mut JournaledState::new(spec_id, HashSet::new()),
            )
            .map_err(|v| ForkCallError::ExecutorError(v.to_string()))
    }
}

#[cfg(test)]

mod tests {
    use super::*;
    use crate::namespace::CreateNamespace;
    use alloy::primitives::U256;
    use alloy::{providers::Provider, sol};
    use rain_interpreter_bindings::{
        DeployerISP::iParserCall,
        IInterpreterStoreV1::{getCall, setCall},
    };
    use rain_interpreter_test_fixtures::LocalEvm;

    sol! {
        interface IERC20 {
            function balanceOf(address account) external view returns (uint256);
            function transfer(address to, uint256 amount) external returns (bool);
            function allowance(address owner, address spender) external view returns (uint256);
            function approve(address spender, uint256 amount) external returns (bool);
            function transferFrom(address from, address to, uint256 amount) external returns (bool);
        }
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_forker_read() {
        let local_evm = LocalEvm::new().await;
        let deployer = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let forker = Forker::new_with_fork(args, None, None).await.unwrap();

        let from_address = Address::default();
        let to_address = deployer;
        let call = iParserCall {};
        let result = forker
            .alloy_call(from_address, to_address, call, false)
            .await
            .unwrap();
        let parser_address = result.typed_return._0;
        let expected_address = *local_evm.parser.address();
        assert_eq!(parser_address, expected_address);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_forker_write() {
        let local_evm = LocalEvm::new().await;
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let mut forker = Forker::new_with_fork(args, None, None).await.unwrap();

        let from_address = Address::repeat_byte(0x02);
        let store_address = *local_evm.store.address();

        let namespace = U256::from(1);
        let key = U256::from(3);
        let value = U256::from(4);
        let _set = forker
            .alloy_call_committing(
                from_address,
                store_address,
                setCall {
                    namespace,
                    kvs: vec![key, value],
                },
                U256::from(0),
                false,
            )
            .await
            .unwrap();

        let fully_quallified_namespace =
            CreateNamespace::qualify_namespace(namespace.into(), from_address);

        let get = forker
            .alloy_call(
                from_address,
                store_address,
                getCall {
                    namespace: fully_quallified_namespace.into(),
                    key: U256::from(3),
                },
                false,
            )
            .await
            .unwrap()
            .typed_return
            ._0;
        assert_eq!(value, get);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_multi_fork_read_write_switch_reset() -> Result<(), ForkCallError> {
        let local_evm1 = LocalEvm::new_with_tokens(1).await;
        let local_evm1_token = *local_evm1.tokens[0].address();
        let local_evm1_token_holder = local_evm1.anvil.addresses()[0];
        let args = NewForkedEvm {
            fork_url: local_evm1.url(),
            fork_block_number: None,
        };
        let mut forker = Forker::new_with_fork(args, None, None).await.unwrap();

        let from_address = Address::default();
        let to_address = local_evm1_token;
        let call = IERC20::balanceOfCall {
            account: local_evm1_token_holder,
        };
        let result = forker
            .alloy_call(from_address, to_address, call, false)
            .await
            .unwrap();
        let old_balance = result.typed_return._0;
        let polygon_old_balance = result.typed_return._0;

        let from_address = local_evm1_token_holder;
        let to_address = local_evm1_token;
        let send_amount = U256::from(0xffu64);
        let transfer_call = IERC20::transferCall {
            to: Address::repeat_byte(0x2),
            amount: send_amount,
        };
        forker
            .alloy_call_committing(
                from_address,
                to_address,
                transfer_call,
                U256::from(0),
                false,
            )
            .await
            .unwrap();

        let from_address = Address::default();
        let to_address = local_evm1_token;
        let call = IERC20::balanceOfCall {
            account: local_evm1_token_holder,
        };
        let result = forker
            .alloy_call(from_address, to_address, call, false)
            .await
            .unwrap();
        let new_balance = result.typed_return._0;
        assert_eq!(new_balance, old_balance - send_amount);
        let polygon_balance = new_balance;

        // switch fork
        let local_evm2 = LocalEvm::new_with_tokens(1).await;
        let local_evm2_token = *local_evm2.tokens[0].address();
        let local_evm2_token_holder = local_evm2.anvil.addresses()[0];
        let args = NewForkedEvm {
            fork_url: local_evm2.url(),
            fork_block_number: None,
        };
        forker.add_or_select(args, None).await?;

        let from_address = Address::default();
        let to_address = local_evm2_token;
        let call = IERC20::balanceOfCall {
            account: local_evm2_token_holder,
        };
        let result = forker
            .alloy_call(from_address, to_address, call, false)
            .await
            .unwrap();
        let old_balance = result.typed_return._0;

        let from_address = local_evm2_token_holder;
        let to_address = local_evm2_token;
        let send_amount = U256::from(0xffu64);
        let transfer_call = IERC20::transferCall {
            to: Address::repeat_byte(0x2),
            amount: send_amount,
        };
        forker
            .alloy_call_committing(
                from_address,
                to_address,
                transfer_call,
                U256::from(0),
                false,
            )
            .await
            .unwrap();

        let from_address = Address::default();
        let to_address = local_evm2_token;
        let call = IERC20::balanceOfCall {
            account: local_evm2_token_holder,
        };
        let result = forker
            .alloy_call(from_address, to_address, call, false)
            .await
            .unwrap();
        let new_balance = result.typed_return._0;
        assert_eq!(new_balance, old_balance - send_amount);

        // switch fork back to fork1
        let args = NewForkedEvm {
            fork_url: local_evm1.url(),
            fork_block_number: None,
        };
        forker.add_or_select(args, None).await?;

        let from_address = Address::default();
        let to_address = local_evm1_token;
        let call = IERC20::balanceOfCall {
            account: local_evm1_token_holder,
        };
        let result = forker
            .alloy_call(from_address, to_address, call, false)
            .await
            .unwrap();
        let balance = result.typed_return._0;
        assert_eq!(balance, polygon_balance);

        // reset fork
        forker.roll_fork(None, None)?;
        let call = IERC20::balanceOfCall {
            account: local_evm1_token_holder,
        };
        let result = forker
            .alloy_call(from_address, to_address, call, false)
            .await
            .unwrap();
        let balance = result.typed_return._0;
        assert_eq!(balance, polygon_old_balance);

        Ok(())
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_rolls() {
        // we need to roll the fork forwards and check that the env block number is updated
        let local_evm = LocalEvm::new().await;
        let block_number = local_evm.provider.get_block_number().await.unwrap() - 2;
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: Some(block_number),
        };
        let mut forker = Forker::new_with_fork(args, None, None).await.unwrap();

        // check the env block number is the same as the fork block number
        assert_eq!(forker.executor.env().block.number, U256::from(block_number));

        // roll the fork forwards by 1 block
        forker.roll_fork(Some(block_number + 1), None).unwrap();

        // check the env block number is updated
        assert_eq!(
            forker.executor.env().block.number,
            U256::from(block_number + 1)
        );
    }
}
