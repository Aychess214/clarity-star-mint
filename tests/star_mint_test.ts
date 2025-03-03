import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

// [Previous test content remains unchanged]
// Additional tests for new functionality:

Clarinet.test({
  name: "Test milestone burning",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get('deployer')!;
    const wallet1 = accounts.get('wallet_1')!;
    
    // First mint a milestone
    let block = chain.mineBlock([
      Tx.contractCall('star-mint', 'mint-milestone',
        [
          types.ascii("First Marathon"),
          types.ascii("Completed my first marathon"),
          types.ascii("2023-10-15"),
          types.ascii("athletic"),
          types.none(),
          types.principal(wallet1.address)
        ],
        deployer.address
      )
    ]);
    
    // Then burn it
    block = chain.mineBlock([
      Tx.contractCall('star-mint', 'burn-milestone',
        [types.uint(1)],
        wallet1.address
      )
    ]);
    
    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectOk().expectBool(true);
  }
});
