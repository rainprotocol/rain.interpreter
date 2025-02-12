use crate::fork::ForkTypedReturn;
use alloy::primitives::{Address, U256};
use foundry_evm::executors::RawCallResult;
use rain_interpreter_bindings::IInterpreterV3::{eval3Call, eval3Return};
use serde::{Deserialize, Serialize};
use std::ops::{Deref, DerefMut};
use thiserror::Error;
#[cfg(target_family = "wasm")]
use wasm_bindgen_utils::{impl_wasm_traits, prelude::*};

pub const RAIN_TRACER_ADDRESS: &str = "0xF06Cd48c98d7321649dB7D8b2C396A81A2046555";

#[derive(Error, Debug)]
pub enum RainEvalResultError {
    #[error("Corrupt traces")]
    CorruptTraces,
}

#[cfg_attr(target_family = "wasm", tsify::declare(type = "string[]"))]
type RainStack = Vec<U256>;

/// A struct representing a single trace from a Rain source. Intended to be decoded
/// from the calldata sent as part of a noop call by the Interpreter to the
/// non-existent tracer contract.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RainSourceTrace {
    pub parent_source_index: u16,
    pub source_index: u16,
    pub stack: RainStack,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RainSourceTraces {
    pub traces: Vec<RainSourceTrace>,
}

impl Deref for RainSourceTraces {
    type Target = Vec<RainSourceTrace>;

    fn deref(&self) -> &Self::Target {
        &self.traces
    }
}

impl DerefMut for RainSourceTraces {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.traces
    }
}

impl FromIterator<RainSourceTrace> for RainSourceTraces {
    fn from_iter<I: IntoIterator<Item = RainSourceTrace>>(iter: I) -> Self {
        RainSourceTraces {
            traces: iter.into_iter().collect(),
        }
    }
}

impl RainSourceTrace {
    fn from_data(data: &[u8]) -> Option<Self> {
        if data.len() < 4 {
            return None;
        }

        // Parse parent and source indices from the next 4 bytes
        let parent_source_index = u16::from_be_bytes([data[0], data[1]]);
        let source_index = u16::from_be_bytes([data[2], data[3]]);

        // Initialize the stack vector
        let mut stack = Vec::new();

        // Start reading stack values after the indices, which is 4 bytes in from the current data slice
        let mut i = 4;
        while i + 32 <= data.len() {
            // Parse each 32-byte segment as a U256 value
            let value = U256::from_be_slice(&data[i..i + 32]);
            stack.push(value);
            i += 32; // Move to the next 32-byte segment
        }

        Some(RainSourceTrace {
            parent_source_index,
            source_index,
            stack,
        })
    }
}

impl RainSourceTraces {
    pub fn flatten(&self) -> RainStack {
        let mut flattened_stack: RainStack = vec![];
        for trace in self.traces.iter() {
            let mut stack = trace.stack.clone();
            stack.reverse();
            for stack_item in stack.iter() {
                flattened_stack.push(*stack_item);
            }
        }
        flattened_stack
    }
    pub fn flattened_path_names(&self) -> Result<Vec<String>, RainEvalResultError> {
        let mut path_names: Vec<String> = vec![];
        let mut source_paths: Vec<String> = vec![];

        for trace in self.iter() {
            let current_path = if trace.parent_source_index == trace.source_index {
                format!("{}", trace.source_index)
            } else {
                source_paths
                    .iter()
                    .rev()
                    .find_map(|recent_path| {
                        recent_path.split('.').last().and_then(|last_part| {
                            if last_part == trace.parent_source_index.to_string() {
                                Some(format!("{}.{}", recent_path, trace.source_index))
                            } else {
                                None
                            }
                        })
                    })
                    .unwrap_or(format!(
                        "{}?.{}",
                        trace.parent_source_index, trace.source_index
                    ))
            };

            for (index, _) in trace.stack.iter().enumerate() {
                path_names.push(format!("{}.{}", current_path, index));
            }

            source_paths.push(current_path);
        }

        Ok(path_names)
    }
}

/// A struct representing the result of a Rain eval call. Contains the stack,
/// writes, and traces. Can be constructed from a `ForkTypedReturn<eval3Call>`.
#[derive(Debug, Clone)]
pub struct RainEvalResult {
    pub reverted: bool,
    pub stack: Vec<U256>,
    pub writes: Vec<U256>,
    pub traces: RainSourceTraces,
}

#[derive(Debug, Clone)]
pub struct RainEvalResults {
    pub results: Vec<RainEvalResult>,
}

impl From<Vec<RainEvalResult>> for RainEvalResults {
    fn from(results: Vec<RainEvalResult>) -> Self {
        RainEvalResults { results }
    }
}

impl Deref for RainEvalResults {
    type Target = Vec<RainEvalResult>;

    fn deref(&self) -> &Self::Target {
        &self.results
    }
}

impl DerefMut for RainEvalResults {
    fn deref_mut(&mut self) -> &mut Self::Target {
        &mut self.results
    }
}

#[derive(Debug, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
#[cfg_attr(target_family = "wasm", derive(Tsify))]
pub struct RainEvalResultsTable {
    pub column_names: Vec<String>,
    pub rows: Vec<RainStack>,
}
#[cfg(target_family = "wasm")]
impl_wasm_traits!(RainEvalResultsTable);

impl RainEvalResults {
    pub fn into_flattened_table(&self) -> Result<RainEvalResultsTable, RainEvalResultError> {
        let column_names = &self.results[0].traces.flattened_path_names()?;
        let mut rows = Vec::new();
        for result in &self.results {
            rows.push(result.traces.flatten());
        }
        Ok(RainEvalResultsTable {
            column_names: column_names.to_vec(),
            rows,
        })
    }
}

impl From<RawCallResult> for RainEvalResult {
    fn from(raw_call_result: RawCallResult) -> Self {
        let tracer_address = RAIN_TRACER_ADDRESS.parse::<Address>().unwrap();

        let mut traces: RainSourceTraces = raw_call_result
            .traces
            .unwrap()
            .to_owned()
            .into_nodes()
            .iter()
            .filter_map(|trace_node| {
                if Address::from(trace_node.trace.address.into_array()) == tracer_address {
                    RainSourceTrace::from_data(&trace_node.trace.data)
                } else {
                    None
                }
            })
            .collect();
        traces.reverse();

        RainEvalResult {
            reverted: raw_call_result.reverted,
            stack: vec![],
            writes: vec![],
            traces,
        }
    }
}

impl From<ForkTypedReturn<eval3Call>> for RainEvalResult {
    fn from(typed_return: ForkTypedReturn<eval3Call>) -> Self {
        let eval3Return { stack, writes } = typed_return.typed_return;

        let res: RainEvalResult = typed_return.raw.into();

        RainEvalResult {
            reverted: res.reverted,
            stack,
            writes,
            traces: res.traces,
        }
    }
}

#[derive(Error, Debug)]
pub enum TraceSearchError {
    #[error("Unparseable trace path: {0}")]
    BadTracePath(String),
    #[error("Trace not found: {0}")]
    TraceNotFound(String),
}

impl RainEvalResult {
    pub fn search_trace_by_path(&self, path: &str) -> Result<U256, TraceSearchError> {
        let mut parts = path.split('.').collect::<Vec<_>>();

        if parts.len() < 2 {
            return Err(TraceSearchError::BadTracePath(path.to_string()));
        }

        let stack_index = parts
            .pop()
            .unwrap()
            .parse::<usize>()
            .map_err(|_| TraceSearchError::BadTracePath(path.to_string()))?;

        let mut current_parent_index = parts[0]
            .parse::<u16>()
            .map_err(|_| TraceSearchError::BadTracePath(path.to_string()))?;
        let mut current_source_index = parts[0]
            .parse::<u16>()
            .map_err(|_| TraceSearchError::BadTracePath(path.to_string()))?;

        for part in parts.iter().skip(1) {
            let next_source_index = part
                .parse::<u16>()
                .map_err(|_| TraceSearchError::BadTracePath(path.to_string()))?;

            if let Some(trace) = self.traces.iter().find(|t| {
                t.parent_source_index == current_parent_index && t.source_index == next_source_index
            }) {
                current_parent_index = trace.parent_source_index;
                current_source_index = trace.source_index;
            } else {
                return Err(TraceSearchError::TraceNotFound(format!(
                    "Trace with parent {}.{} not found",
                    current_parent_index, next_source_index
                )));
            }
        }
        self.traces
            .iter()
            .find(|t| {
                t.parent_source_index == current_parent_index
                    && t.source_index == current_source_index
            })
            .ok_or_else(|| {
                TraceSearchError::TraceNotFound(format!(
                    "Trace with parent {}.{} not found",
                    current_parent_index, current_source_index
                ))
            })
            .and_then(|trace| {
                // Reverse the stack order to account for the last item being at index 0
                let reversed_stack_index = trace.stack.len().checked_sub(stack_index + 1).ok_or(
                    TraceSearchError::TraceNotFound(format!(
                        "Stack index {} out of bounds in trace {}.{}",
                        stack_index, current_parent_index, current_source_index
                    )),
                )?;

                trace.stack.get(reversed_stack_index).cloned().ok_or(
                    TraceSearchError::TraceNotFound(format!(
                        "Reversed stack index {} not found in trace {}.{}",
                        reversed_stack_index, current_parent_index, current_source_index
                    )),
                )
            })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::eval::ForkEvalArgs;
    use crate::fork::{Forker, NewForkedEvm};
    use alloy::primitives::utils::parse_ether;
    use rain_interpreter_bindings::IInterpreterStoreV1::FullyQualifiedNamespace;
    use rain_interpreter_test_fixtures::LocalEvm;

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_fork_trace() {
        let local_evm = LocalEvm::new().await;
        let deployer = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();

        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"
                a: add(1 2),
                b: 2,
                c: 4,
                _: call<1>(1 2),
                :set(1 2),
                :set(3 4);
                a b:,
                c: call<2>(a b),
                d: add(a b);
                a b:,
                c: mul(a b);
                "
                .into(),
                source_index: 0,
                deployer,
                namespace: FullyQualifiedNamespace::default(),
                context: vec![],
                decode_errors: true,
            })
            .await
            .unwrap();

        let rain_eval_result = RainEvalResult::from(res);

        // reverted
        assert!(!rain_eval_result.reverted);
        // stack
        let expected_stack = vec_i32_to_u256(vec![3, 4, 2, 3]);
        assert_eq!(rain_eval_result.stack, expected_stack);

        // storage writes
        let expected_writes = vec_i32_to_u256(vec![3, 4, 1, 2]);
        assert_eq!(rain_eval_result.writes, expected_writes);

        // stack traces
        // 0 0
        let trace_0 = RainSourceTrace {
            parent_source_index: 0,
            source_index: 0,
            stack: vec_i32_to_u256(vec![3, 4, 2, 3]),
        };
        assert_eq!(rain_eval_result.traces[0], trace_0);
        // 0 1
        let trace_1 = RainSourceTrace {
            parent_source_index: 0,
            source_index: 1,
            stack: vec_i32_to_u256(vec![3, 2, 2, 1]),
        };
        assert_eq!(rain_eval_result.traces[1], trace_1);
        // 1 2
        let trace_2 = RainSourceTrace {
            parent_source_index: 1,
            source_index: 2,
            stack: vec_i32_to_u256(vec![2, 2, 1]),
        };
        assert_eq!(rain_eval_result.traces[2], trace_2);
    }

    #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
    async fn test_search_trace_by_path() {
        let local_evm = LocalEvm::new().await;
        let deployer = *local_evm.deployer.address();
        let args = NewForkedEvm {
            fork_url: local_evm.url(),
            fork_block_number: None,
        };
        let fork = Forker::new_with_fork(args, None, None).await.unwrap();

        let res = fork
            .fork_eval(ForkEvalArgs {
                rainlang_string: r"
                a: add(1 2),
                b: 2,
                c: 4,
                _: call<1>(1 2);
                a b:,
                c: call<2>(a b),
                d: add(a b);
                a b:,
                c: mul(a b);
                "
                .into(),
                source_index: 0,
                deployer,
                namespace: FullyQualifiedNamespace::default(),
                context: vec![],
                decode_errors: true,
            })
            .await
            .unwrap();

        let rain_eval_result = RainEvalResult::from(res);

        // search_trace_by_path
        let trace_0 = rain_eval_result.search_trace_by_path("0.1").unwrap();
        assert_eq!(trace_0, parse_ether("2").unwrap());
        let trace_1 = rain_eval_result.search_trace_by_path("0.1.3").unwrap();
        assert_eq!(trace_1, parse_ether("3").unwrap());
        let trace_2 = rain_eval_result.search_trace_by_path("0.1.2").unwrap();
        assert_eq!(trace_2, parse_ether("2").unwrap());

        // test the various errors
        // bad trace path
        let result = rain_eval_result.search_trace_by_path("0");
        assert!(matches!(result, Err(TraceSearchError::BadTracePath(_))));
        let result = rain_eval_result.search_trace_by_path("0.1.");
        assert!(matches!(result, Err(TraceSearchError::BadTracePath(_))));

        let result = rain_eval_result.search_trace_by_path("0.1.12");
        assert!(matches!(result, Err(TraceSearchError::TraceNotFound(_))));
    }

    #[test]
    fn test_rain_source_trace_from_data() {
        // stack items are 32 bytes each
        let stack_items = [U256::from(1), U256::from(2), U256::from(3)];
        let stack_data: Vec<u8> = stack_items
            .iter()
            .flat_map(|x| x.to_be_bytes_vec())
            .collect();

        let source_indices = [
            0x00, 0x01, 0x00, 0x02, // parent_source_index: 1, source_index: 2
        ];

        // concat source indices and stack data
        let data: Vec<u8> = source_indices
            .iter()
            .chain(stack_data.iter())
            .copied()
            .collect();

        let trace = RainSourceTrace::from_data(&data).unwrap();

        assert_eq!(trace.parent_source_index, 1);
        assert_eq!(trace.source_index, 2);
        assert_eq!(trace.stack.len(), 3);
        assert_eq!(trace.stack[0], U256::from(1));
    }

    #[test]
    fn test_rain_source_traces_deref() {
        let trace1 = RainSourceTrace {
            parent_source_index: 1,
            source_index: 1, // Adjusted to have the same parent and source index for consistency
            stack: vec![U256::from(1)],
        };
        let trace2 = RainSourceTrace {
            parent_source_index: 1, // Adjusted to match the parent_source_index
            source_index: 2,
            stack: vec![U256::from(2)],
        };

        let traces = RainSourceTraces {
            traces: vec![trace1.clone(), trace2.clone()],
        };

        assert_eq!(traces[0], trace1);
        assert_eq!(traces[1], trace2);
    }

    #[test]
    fn test_rain_source_traces_flatten() {
        let trace1 = RainSourceTrace {
            parent_source_index: 1,
            source_index: 1, // Adjusted to match the test case
            stack: vec![U256::from(1), U256::from(2)],
        };
        let trace2 = RainSourceTrace {
            parent_source_index: 1, // Adjusted to match the parent_source_index
            source_index: 2,
            stack: vec![U256::from(3)],
        };

        let traces = RainSourceTraces {
            traces: vec![trace1, trace2],
        };

        let flattened_stack = traces.flatten();
        assert_eq!(
            flattened_stack,
            vec![U256::from(2), U256::from(1), U256::from(3)]
        );
    }

    #[test]
    fn test_rain_source_traces_flattened_path_names() {
        let trace1 = RainSourceTrace {
            parent_source_index: 1,
            source_index: 1, // Adjusted to match the test case
            stack: vec![U256::from(1), U256::from(2)],
        };
        let trace2 = RainSourceTrace {
            parent_source_index: 1, // Adjusted to match the parent_source_index
            source_index: 2,
            stack: vec![U256::from(3)],
        };

        let traces = RainSourceTraces {
            traces: vec![trace1, trace2],
        };

        let path_names = traces.flattened_path_names().unwrap();
        assert_eq!(path_names, vec!["1.0", "1.1", "1.2.0"]);
    }

    #[test]
    fn test_rain_eval_result_into_flattened_table() {
        let trace1 = RainSourceTrace {
            parent_source_index: 1,
            source_index: 1, // Adjusted to match the test case
            stack: vec![U256::from(1), U256::from(2)],
        };
        let trace2 = RainSourceTrace {
            parent_source_index: 1, // Adjusted to match the parent_source_index
            source_index: 2,
            stack: vec![U256::from(3)],
        };

        let rain_eval_result = RainEvalResult {
            reverted: false,
            stack: vec![],
            writes: vec![],
            traces: RainSourceTraces {
                traces: vec![trace1, trace2],
            },
        };

        let rain_eval_results = RainEvalResults {
            results: vec![rain_eval_result],
        };

        let table = rain_eval_results.into_flattened_table().unwrap();
        assert_eq!(table.column_names, vec!["1.0", "1.1", "1.2.0"]);
        assert_eq!(table.rows.len(), 1);
        assert_eq!(
            table.rows[0],
            vec![U256::from(2), U256::from(1), U256::from(3)]
        );
    }

    fn vec_i32_to_u256(vec: Vec<i32>) -> Vec<U256> {
        vec.iter()
            .map(|&x| parse_ether(&x.to_string()).unwrap())
            .collect()
    }
}
