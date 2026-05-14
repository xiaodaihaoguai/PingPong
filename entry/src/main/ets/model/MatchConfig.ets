export type PlayerSide = "left" | "right"

@ObservedV2
export class MatchConfig {
  @Trace bestOf: number = 5
  @Trace playerLeftName: string = "我"
  @Trace playerRightName: string = "对手"
  @Trace startingServer: PlayerSide = "left"

  get gamesToWin(): number {
    return Math.ceil(this.bestOf / 2)
  }

  isDecidingGame(currentGame: number): boolean {
    return currentGame === this.bestOf
  }
}
