import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
  // html側でdata-autocomplete-target="input".JS側で static targets = ["input"] と定義すれば、this.inputTarget で操作することになる。イベントではなく場所
  static targets = ["input"]

  // 送信時に候補を消すための処理 ---
  clear() {
    const frame = document.getElementById("search_results")
    if (frame) frame.innerHTML = ""
    // 実行待ちの検索予約もキャンセルしておく
    clearTimeout(this.timeout)
  }

  search() {
    // 1文字打つたびに前の予約を消すことで高速タイピング中はサーバー通信を削減
    // clearTimeoutはjs標準の「予約キャンセルボタン」。()内の引数が存在すれば(予約IDがあれば)実行。
    clearTimeout(this.timeout)

    // this.inputTarget: htmlで付与したinput要素。
    // .trim(): 値の前後の余白を削除
    const value = this.inputTarget.value.trim()

    if (value === "") {
      this.clear() // 共通化したクリア処理を呼ぶ
      return
    }

    // this.timeoutは0.3秒後にフォームを送信する予約。戻り値として識別IDを返す。
    this.timeout = setTimeout(() => {
      // this.element:コントローラーが貼り付けられているhtml要素そのもの
      // 「あ」と入力したら0.3秒後に文字通り「あ」でフォームを送信する。search_resultsフレームだけ更新される
      this.form.requestSubmit()
    }, 300)
  }

  select(event) {
    const value = event.currentTarget.dataset.value

    // this.inputTarget: htmlで付与したinput要素。
    this.inputTarget.value = value

    // 候補を消す
    this.clear() // 共通化したクリア処理を呼ぶ
    // selectではsubmitしない。検索ボタンに任せる
  }

  // ゲッター: this.formと書いた時、裏でこの処理が実行される
  // htmlに幾つかのformタグがあると仮定して、ターゲットで指定したものを確実に指定するための処置
  get form() {
    // closest("form"): 最初に見つかったformを返す
    return this.inputTarget.closest("form")
  }
}