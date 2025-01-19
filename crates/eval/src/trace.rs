use crate::fork::ForkTypedReturn;
use alloy::primitives::{Address, U256};
use rain_interpreter_bindings::IInterpreterV4::{eval4Call, eval4Return};

use thiserror::Error;

pub const RAIN_TRACER_ADDRESS: &str = "0xF06Cd48c98d7321649dB7D8b2C396A81A2046555";

/// A struct representing a single trace from a Rain source. Intended to be decoded
/// from the calldata sent as part of a noop call by the Interpreter to the
/// non-existent tracer contract.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RainSourceTrace {
    pub parent_source_index: u16,
    pub source_index: u16,
    pub stack: Vec<U256>,
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

/// A struct representing the result of a Rain eval call. Contains the stack,
/// writes, and traces. Can be constructed from a `ForkTypedReturn<eval4Call>`.
#[derive(Debug, Clone)]
pub struct RainEvalResult {
    pub reverted: bool,
    pub stack: Vec<U256>,
    pub writes: Vec<U256>,
    pub traces: Vec<RainSourceTrace>,
}

impl From<ForkTypedReturn<eval4Call>> for RainEvalResult {
    fn from(typed_return: ForkTypedReturn<eval4Call>) -> Self {
        let eval4Return { stack, writes } = typed_return.typed_return;

        let tracer_address = RAIN_TRACER_ADDRESS.parse::<Address>().unwrap();
        let mut traces: Vec<RainSourceTrace> = typed_return
            .raw
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
            reverted: typed_return.raw.reverted,
            stack,
            writes,
            traces,
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

//  --------------------- @todo -----------------

// #[cfg(test)]
// mod tests {
//     use super::*;
//     use crate::eval::ForkEvalArgs;
//     use crate::fork::{Forker, NewForkedEvm};
//     use alloy::primitives::utils::parse_ether;
//     use rain_interpreter_bindings::IInterpreterStoreV2::FullyQualifiedNamespace;
//     use rain_interpreter_test_fixtures::LocalEvm;

//     #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
//     async fn test_fork_trace() {
//         let local_evm = LocalEvm::new().await;
//         let deployer = *local_evm.deployer.address();
//         let args = NewForkedEvm {
//             fork_url: local_evm.url(),
//             fork_block_number: None,
//         };
//         let fork = Forker::new_with_fork(args, None, None).await.unwrap();

//         let res = fork
//             .fork_eval(ForkEvalArgs {
//                 rainlang_string: r"
//                 a: add(1 2),
//                 b: 2,
//                 c: 4,
//                 _: call<1>(1 2),
//                 :set(1 2),
//                 :set(3 4);
//                 a b:,
//                 c: call<2>(a b),
//                 d: add(a b);
//                 a b:,
//                 c: mul(a b);
//                 "
//                 .into(),
//                 source_index: 0,
//                 deployer,
//                 namespace: FullyQualifiedNamespace::default(),
//                 context: vec![],
//                 decode_errors: true,
//             })
//             .await
//             .unwrap();

//         let rain_eval_result = RainEvalResult::from(res);

//         // reverted
//         assert!(!rain_eval_result.reverted);
//         // stack
//         let expected_stack = vec_i32_to_u256(vec![3, 4, 2, 3]);
//         assert_eq!(rain_eval_result.stack, expected_stack);

//         // storage writes
//         let expected_writes = vec_i32_to_u256(vec![3, 4, 1, 2]);
//         assert_eq!(rain_eval_result.writes, expected_writes);

//         // stack traces
//         // 0 0
//         let trace_0 = RainSourceTrace {
//             parent_source_index: 0,
//             source_index: 0,
//             stack: vec_i32_to_u256(vec![3, 4, 2, 3]),
//         };
//         assert_eq!(rain_eval_result.traces[0], trace_0);
//         // 0 1
//         let trace_1 = RainSourceTrace {
//             parent_source_index: 0,
//             source_index: 1,
//             stack: vec_i32_to_u256(vec![3, 2, 2, 1]),
//         };
//         assert_eq!(rain_eval_result.traces[1], trace_1);
//         // 1 2
//         let trace_2 = RainSourceTrace {
//             parent_source_index: 1,
//             source_index: 2,
//             stack: vec_i32_to_u256(vec![2, 2, 1]),
//         };
//         assert_eq!(rain_eval_result.traces[2], trace_2);
//     }

//     #[tokio::test(flavor = "multi_thread", worker_threads = 1)]
//     async fn test_search_trace_by_path() {
//         let local_evm = LocalEvm::new().await;
//         let deployer = *local_evm.deployer.address();
//         let args = NewForkedEvm {
//             fork_url: local_evm.url(),
//             fork_block_number: None,
//         };
//         let fork = Forker::new_with_fork(args, None, None).await.unwrap();

//         let res = fork
//             .fork_eval(ForkEvalArgs {
//                 rainlang_string: r"
//                 a: add(1 2),
//                 b: 2,
//                 c: 4,
//                 _: call<1>(1 2);
//                 a b:,
//                 c: call<2>(a b),
//                 d: add(a b);
//                 a b:,
//                 c: mul(a b);
//                 "
//                 .into(),
//                 source_index: 0,
//                 deployer,
//                 namespace: FullyQualifiedNamespace::default(),
//                 context: vec![],
//                 decode_errors: true,
//             })
//             .await
//             .unwrap();

//         let rain_eval_result = RainEvalResult::from(res);

//         // search_trace_by_path
//         let trace_0 = rain_eval_result.search_trace_by_path("0.1").unwrap();
//         assert_eq!(trace_0, parse_ether("2").unwrap());
//         let trace_1 = rain_eval_result.search_trace_by_path("0.1.3").unwrap();
//         assert_eq!(trace_1, parse_ether("3").unwrap());
//         let trace_2 = rain_eval_result.search_trace_by_path("0.1.2").unwrap();
//         assert_eq!(trace_2, parse_ether("2").unwrap());

//         // test the various errors
//         // bad trace path
//         let result = rain_eval_result.search_trace_by_path("0");
//         assert!(matches!(result, Err(TraceSearchError::BadTracePath(_))));
//         let result = rain_eval_result.search_trace_by_path("0.1.");
//         assert!(matches!(result, Err(TraceSearchError::BadTracePath(_))));

//         let result = rain_eval_result.search_trace_by_path("0.1.12");
//         assert!(matches!(result, Err(TraceSearchError::TraceNotFound(_))));
//     }

//     fn vec_i32_to_u256(vec: Vec<i32>) -> Vec<U256> {
//         vec.iter()
//             .map(|&x| parse_ether(&x.to_string()).unwrap())
//             .collect()
//     }
// }
