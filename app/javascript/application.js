// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import $ from "jquery";
import "jquery-raty"; 

// 評価ウィジェットを初期化する関数
const initializeRaty = () => {
  const options = {
    number: 5,
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
};


// 1. DOMが完全に準備されたときに実行
$(function() {
    initializeRaty();
});

// 2. Turboがページ遷移・復元したときに実行
$(document).on("turbo:load", initializeRaty);