import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
  // html側でdata-autocomplete-target="input".JS側で static targets = ["input"] と定義すれば、this.inputTarget で操作することになる。イベントではなく場所
  static targets = ["input"]

  connect() {
    console.log("オートコンプリート準備完了！")
  }

  search() {
    // 1文字打つたびに前の予約を消すことで高速タイピング中はサーバー通信を削減
    // clearTimeoutはjs標準の「予約キャンセルボタン」。()内の引数が存在すれば(予約IDがあれば)実行。
    clearTimeout(this.timeout)
    // this.timeoutは0.3秒後にフォームを送信する予約。戻り値として識別IDを返す。
    this.timeout = setTimeout(() => {
      // this.element:コントローラーが貼り付けられているhtml要素そのもの
      // 「あ」と入力したら0.3秒後に文字通り「あ」でフォームを送信する
      this.element.requestSubmit()
    }, 300)
  }
}
// このコントローラーだけの処理ではフォームを送信のたびにリロードを挟む。
// これを防いで「検索結果のリストだけ」を入れ替えるため Turbo Frame（ターボフレーム）という技術を用いる
