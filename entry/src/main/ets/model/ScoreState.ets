import { PlayerSide } from "./MatchConfig"

export type GamePhase = "playing" | "game_over" | "match_over"

export interface GameResult {
  gameNumber: number
  scoreLeft: number
  scoreRight: number
}

@ObservedV2
export class ScoreState {
  @Trace gamesLeft: number = 0
  @Trace gamesRight: number = 0
  @Trace pointsLeft: number = 0
  @Trace pointsRight: number = 0
  @Trace currentGame: number = 1
  @Trace sidesSwapped: boolean = false
  @Trace phase: GamePhase = "playing"
  @Trace winner: PlayerSide | null = null
  @Trace history: GameResult[] = []

  // 换场提示标记：当前是否需要提示换场
  @Trace shouldSwapSides: boolean = false
  // 换场原因描述
  @Trace swapReason: string = ""
}
