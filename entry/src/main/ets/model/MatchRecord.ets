import { PlayerSide } from "./MatchConfig"
import { GameResult } from "./ScoreState"

export interface MatchRecord {
  id: number
  createdAt: number
  bestOf: number
  playerLeftName: string
  playerRightName: string
  gamesLeft: number
  gamesRight: number
  winner: PlayerSide | null
  games: GameResult[]
}
