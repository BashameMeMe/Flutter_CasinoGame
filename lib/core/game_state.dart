class GameState {
  static bool canBet(int amount, int balance) {
    return amount > 0 && amount <= balance;
  }

  static int winAmount(int bet) => bet * 2;
}
