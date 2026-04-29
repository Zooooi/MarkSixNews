# MarkSixNews
這是一個為你的新聞推送系統準備的 **README.md**。它包含了系統架構說明、JSON 配置指南以及 Flutter 端的核心邏輯介紹，方便你日後維護或與他人協作。

---

# Flutter 動態新聞推送系統 (JSON 版)

這是一個基於 Flutter 的遠端配置系統，透過 GitHub Pages 託管的 `JSON` 檔案，實現對 App 新聞彈窗的動態控制。支援定時、次數限制、正式版判斷及自適應佈局。

## 🚀 主要功能
* **動態開關**：透過 `enable` 參數隨時下架新聞，並自動清理手機本地緩存。
* **精確排程**：
    * `specificTime`: 指定日期時間彈出。
    * `delayHours`: App 啟動後延遲特定小時數彈出。
* **頻率控制**：自定義最大顯示次數 (`maxCount`) 與兩次顯示間的最小間隔 (`intervalHours`)。
* **環境感知**：支援僅在 Release 模式下顯示的新聞。
* **自適應 UI**：JSON 設置 `width` 或 `height` 為 `0` 時，彈窗將根據 HTML 內容長度自適應縮放。

---

## 📄 JSON 配置指南 (`news_config.json`)

請將配置檔放在 `https://<your-github-io>/news_config.json`。

```json
{
  "news_list": [
    {
      "id": "promo_2026_01",
      "html_url": "https://yourname.github.io/pages/promo.html",
      "policy": {
        "enable": true,            
        "release": false,      
        "specificTime": "2026-04-15 10:00:00", 
        "showOnStart": true,       
        "delayHours": 0.0,         
        "intervalHours": 24,       
        "maxCount": 3,
        "expired":"2026-12-31"             
      },
      "layout": {
        "width": 350.0,            
        "height": 0,               
        "padding": 20.0            
      }
    }
  ]
}
```

### 參數詳解
| 參數 | 類型 | 說明 |
| :--- | :--- | :--- |
| `id` | String | 唯一識別碼。修改此 ID 會重置用戶的閱讀計數。 |
| `enable` | bool | 總開關。設為 `false` 時，App 會自動刪除該 ID 的本地紀錄。 |
| `release` | bool | 設為 `true` 時，開發模式下不會彈出。 |
| `specificTime` | String | 格式 `YYYY-MM-DD HH:mm:ss`。若設定且時間未到，將自動倒數。 |
| `delayHours` | double | 啟動 App 後等待多久（小時）。`0.5` 代表 30 分鐘。 |
| `intervalHours`| int | 兩次彈窗間隔的小時數。 |
| `maxCount` | int | 該新聞對同一用戶顯示的總次數上限。`-1` 為無限。 |
| `width / height`| double | 設為 `0` 時，UI 會根據內容自動調整。 |

---

## 🛠️ 技術實作

系統採用三層架構分離邏輯：

### 1. 數據層 (`NewsModel`)
負責將 JSON 數據轉換為 Dart 對象，並處理「0 轉為 null」的自適應佈局邏輯。

### 2. 服務層 (`NewsService`)
* **網路**：使用 `http` 獲取遠端 JSON。
* **持久化**：使用 `shared_preferences` 存儲 `{id}_count` 與 `{id}_last` 顯示時間。
* **清理**：當新聞停用時，負責執行 `remove` 操作清理過期數據。

### 3. 控制層 (`NewsCtrl`)
* **生命週期管理**：與 `flutter_hooks` 結合，自動在頁面銷毀時取消所有 `Timer`。
* **安全性**：嚴格執行 `context.mounted` 檢查，避免在異步等待後導致的記憶體洩漏或 UI 崩潰。

---

## ⚠️ 注意事項
1.  **時間格式**：`specificTime` 務必遵循標準格式，否則 `DateTime.tryParse` 會失敗。
2.  **HTML 內容**：建議 HTML 內部使用相對路徑或 CDN 連結，並確保圖片設有 `max-width: 100%` 以適應行動端螢幕。
3.  **網路超時**：如果 GitHub Pages 連線不穩，`NewsService` 設有異常捕獲，不會影響 App 主流程運行。
