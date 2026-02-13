// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import $ from "jquery";
import "jquery-raty";
import "@hotwired/turbo-rails"
import "controllers";
// import Rails from "@rails/ujs"
// ファイル選択で画像リサイズ
import "custom/image_compression"
// Rails.start()

// --------------------------------
// 五つ星
// 評価ウィジェットを初期化する関数
const initializeRaty = () => {
  // 設定オプションをまとめたオブジェクト
  const options = {
    number: 5,
    // Font Awesomeの<i>アイコンを使用
    starType: 'i',
    starOff: 'far fa-star',
    starOn: 'fas fa-star',
    starHalf: 'fas fa-star-half-alt',

    click: function(score, event) {
      $(this).siblings('input[type="hidden"]').val(score);
    },

    score: function() {
      return $(this).siblings('input[type="hidden"]').val();
    }
  };

  // 全てのレーティング用divに対してratyを初期化
  $('#aroma-rating').raty(options);
  $('#taste-rating').raty(options);
  $('#price-rating').raty(options);

  // #sweet-rating … 星を描画するHTML要素（div）
  // #sweet-score … 選んだ星の数を格納するhidden input
  $('#sweet-rating').raty(options);
  $('#spicy-rating').raty(options);
  $('#bitter-rating').raty(options);
  $('#green-rating').raty(options);
  $('#fruity-rating').raty(options);

};

// 1. DOMが完全に準備されたときに実行。通常のページ読み込み（リロード時など）
$(function() {
    initializeRaty();
});

// 2. Turboによる遷移
$(document).on("turbo:load", initializeRaty);

// 3. バリデーションエラー等での再描画時に実行
$(document).on("turbo:render", initializeRaty);

// --------------------------------
// product送信前に選択中の画像を表示する
document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("product_images");
  const preview = document.getElementById("preview");

  if (input) {
    input.addEventListener("change", (event) => {
      preview.innerHTML = ""; // 以前のプレビューをリセット
      Array.from(event.target.files).forEach(file => {
        if (!file.type.match("image.*")) {
          return;
        }
        const reader = new FileReader();
        reader.onload = (e) => {
          const img = document.createElement("img");
          img.src = e.target.result;
          img.style.maxWidth = "200px";
          img.style.margin = "0.5rem";
          preview.appendChild(img);
        };
        reader.readAsDataURL(file);
      });
    });
  }
});
// --------------------------------
// post送信前に選択中の画像を表示する
document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("post_images");
  const preview = document.getElementById("preview");

  if (input) {
    input.addEventListener("change", (event) => {
      preview.innerHTML = ""; // 以前のプレビューをリセット
      Array.from(event.target.files).forEach(file => {
        if (!file.type.match("image.*")) {
          return;
        }
        const reader = new FileReader();
        reader.onload = (e) => {
          const img = document.createElement("img");
          img.src = e.target.result;
          img.style.maxWidth = "200px";
          img.style.margin = "0.5rem";
          preview.appendChild(img);
        };
        reader.readAsDataURL(file);
      });
    });
  }
});
// --------------------------------import "controllers"
