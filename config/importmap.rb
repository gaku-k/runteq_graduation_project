# Pin npm packages by running ./bin/importmap

pin "application"
pin "jquery" # @3.7.1
pin "jquery-raty", to: "jquery.raty.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
# app/javascript/custom/test.js を作った場合、app/javascript/application.js に import "custom/test" と書く
pin_all_from "app/javascript/custom", under: "custom"
pin "@rails/ujs", to: "@rails--ujs.js" # @7.1.3
pin "browser-image-compression" # @2.0.2
