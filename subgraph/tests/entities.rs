mod generated;
mod utils;

#[tokio::main]
#[test]
async fn test_deployer() -> anyhow::Result<()> {
    let deployer_0 = utils::setup::get_deployer().await?;
    println!("deployer_0: {:?}", deployer_0.address());

    Ok(())
}