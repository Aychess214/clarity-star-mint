import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Test milestone minting",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    let block = chain.mineBlock([
      Tx.contractCall('star-mint', 'mint-milestone',
        [
          types.ascii("First Marathon"),
          types.ascii("Completed my first marathon"),
          types.ascii("2023-10-15"),
          types.ascii("athletic"),
          types.principal(wallet1.address)
        ],
        deployer.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectUint(1);
    
    let response = chain.callReadOnlyFn(
      'star-mint',
      'get-milestone-details',
      [types.uint(1)],
      deployer.address
    );

    const milestone = response.result.expectOk().expectSome();
    assertEquals(milestone.title, "First Marathon");
    assertEquals(milestone.owner, wallet1.address);
  }
});

Clarinet.test({
  name: "Test milestone transfer",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    const wallet2 = accounts.get('wallet_2')!;
    
    // First mint a milestone
    let block = chain.mineBlock([
      Tx.contractCall('star-mint', 'mint-milestone',
        [
          types.ascii("First Marathon"),
          types.ascii("Completed my first marathon"),
          types.ascii("2023-10-15"),
          types.ascii("athletic"),
          types.principal(wallet1.address)
        ],
        deployer.address
      )
    ]);
    
    // Then transfer it
    block = chain.mineBlock([
      Tx.contractCall('star-mint', 'transfer-milestone',
        [types.uint(1), types.principal(wallet2.address)],
        wallet1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
    
    // Verify new owner
    let response = chain.callReadOnlyFn(
      'star-mint',
      'get-milestone-owner',
      [types.uint(1)],
      deployer.address
    );
    
    response.result.expectOk().expectSome().assertEquals(wallet2.address);
  }
});
