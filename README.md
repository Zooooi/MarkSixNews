# MarkSixNews

# Flutter 動態公告推送系統 (進階政策與外觀控制版)

這是一個基於 Flutter 的遠端動態公告系統，透過託管在遠端伺服器（如 GitHub Pages）的 `JSON` 配置文件，實現對 App 公告彈窗的動態精確控制。

本系統支援**精確排程、冷卻時間控制、每日上限、今天不再提示、強制公告鎖定（維護/強更通知）以及點擊導頁跳轉動作**。

---

## 🚀 核心功能
* **重置防禦機制**：當 App 從背景返回（Resume）超時重新觸發初始化時，系統會自動清理上一輪的所有 `Timer` 倒數，完美防止計時器疊加導致公告重複彈出的隱患。
* **強大的頻率控制**：
  * 總次數上限 (`maxCount`) 與冷卻間隔 (`intervalHours`)。
  * **[新]** 每日最高顯示次數 (`maxCountPerDay`)。
* **[新] 使用者體驗優化**：支援「今天不再顯示」勾選框，勾選後當天自動攔截不再打擾用戶。
* **[新] 強制公告 (Force Mode)**：當啟用 `force: true` 時，彈窗會隱藏關閉按鈕、防鎖死點擊外部空白處關閉，並使用新版 `PopScope` 攔截 Android 實體返回鍵。適合用作維護或強制更新公告。
* **[新] 導頁動作 (Action System)**：公告不只是觀看，還可以設定點擊跳轉到 App 內部指定路由頁面（如儲值頁、活動頁）或透過外部瀏覽器開啟。

---

## 📄 JSON 配置指南 (`news_config.json`)

```json
{
  "news_list": [
    {
      "id": "old_event_2025",
      "html_url": "...",
      "policy": {
        "enable": false
      }
    },
    {
      "id": "new_event_2026",
      "html_url": "index.html",
      "action_type": "inner_route",
      "action_value": "/deposit",
      "policy": {
        "enable": true,
        "release": false,
        "specificTime": "",
        "showOnStart": true,
        "delayHours": 0.05,
        "intervalHours": 12,
        "maxCount": 3,
        "maxCountPerDay": 1,
        "force": false,
        "showNeverAgain": true,
        "expired": "2026-12-31"
      },
      "layout": {
        "width": 0,
        "height": 0,
        "padding": 16.0
      }
    }
  ]
}

```

### 參數詳解

#### 1. 根節點參數

| 參數 | 類型 | 說明 |
| --- | --- | --- |
| `id` | String | 唯一識別碼。修改此 ID 會自動重置該公告在用戶手機上的所有閱讀與冷卻計數。 |
| `html_url` | String | 網頁路徑。若不以 `http` 開頭，系統會自動與配置的 `baseUrl` 拼接成完整網址。 |
| `action_type` | String | 點擊「查看詳情」按鈕的動作類型。可選：`none` (無按鈕), `inner_route` (內導路由), `external_url` (外部瀏覽器)。 |
| `action_value` | String | 動作對應的值。例如路由名稱 `/deposit` 或網址 `https://...`。 |

#### 2. 政策控制 (`policy`)

| 參數 | 類型 | 說明 |
| --- | --- | --- |
| `enable` | bool | 總開關。設為 `false` 或公告已過期時，App 會自動刪除該 ID 的本地持久化緩存。 |
| `release` | bool | 設為 `true` 時，僅在生產環境（Release Mode）下彈出，開發環境下自動跳過。 |
| `specificTime` | String | 指定彈出時間（格式：`YYYY-MM-DD HH:mm:ss`）。若時間未到，系統會精準啟動計時器進行倒數。 |
| `showOnStart` | bool | 在滿足延遲時間後是否在啟動時顯示。 |
| `delayHours` | double | 延遲觸發時間（小時）。例如 `0.05` 代表約 3 分鐘，`0.0` 代表立即觸發。 |
| `intervalHours` | int | 兩次彈窗顯示之間的最小冷卻時間（小時）。 |
| `maxCount` | int | 該公告對同一用戶顯示的總次數上限。`-1` 為無限次。 |
| `maxCountPerDay` | int | 該公告在**單日**內對同一用戶顯示的上限次數。`-1` 為不限制。 |
| `force` | bool | 是否為強制公告。設為 `true` 時會封鎖所有關閉管道（返回鍵、空白處），且不顯示勾選框。 |
| `showNeverAgain` | bool | 是否開啟「今天不再顯示」勾選框（僅在 `force: false` 時有效）。 |
| `expired` | String | 公告過期截止日期（格式：`YYYY-MM-DD`）。超過此日期後公告自動失效。 |

#### 3. 佈局外觀 (`layout`)

| 參數 | 類型 | 說明 |
| --- | --- | --- |
| `width` | double | 彈窗寬度。設為 `0` 時，系統會自動根據設備尺寸自適應調整（平板 75% 寬，手機 85% 寬）。 |
| `height` | double | 彈窗高度。設為 `0` 時，預設為螢幕高度的 60%。 |
| `padding` | double | 網頁容器的內邊距，預設為 `16.0`。 |

---

## 🛠️ 技術架構與實作

系統採用三層分層架構，職責清晰，利於擴充：

### 1. 數據層 (`NewsData`)

* 負責將 JSON 配置安全解析為 Dart 物件，並透過 `DataFormat` 工具類別進行嚴格的防禦性轉型（避免型別不符引發的 App 閃退）。
* 內建 `isExpiredAt(DateTime now)` 語意化方法，精準判定公告時效。

### 2. 服務層 (`NewsService`)

* **遠端讀取**：負責透過 `http` 套件抓取配置，並完成網頁相對路徑的自動拼接。
* **狀態標記**：負責將公告的基本顯示次數與最後顯示時間進行記錄與讀取判定。

### 3. 控制層 (`NewsViewCtrl`)

* **防重疊重置機制**：在 `init()` 頂層呼叫 `_clearTimers()`。在 App 生命週期超時重啟或手動刷新時，能完美洗掉上一輪的所有計時器。
* **高安全性非同步處理**：全流程嚴格在異步等待節點（Async Gap）後加入 `context.mounted` 與 `ctx.mounted` 檢查，完全根除記憶體洩漏與對已銷毀 Context 操作導致的 UI 崩潰。
* **局部狀態刷新**：在 Dialog 內部巧妙運用 `StatefulBuilder` 來管理「今天不再顯示」Checkbox 的勾選狀態，精準重新渲染局部組件，維持高效能表現。
* **新版組件標準**：完全廢棄已棄用的 `WillPopScope`，改用 Flutter 官方最新的 **`PopScope(canPop: !news.force)`** 組件，無縫適應 Android 的預測性返回手勢（Predictive Back Feature）。
* **統一儲存橋接**：透過專案核心的 `PrefStorage()` 統一存取 `SharedPreferences` 的命名空間，確保 Key 的管理規則不散落。

---

## ⚠️ 運營維護注意事項

1. **快取清理**：當某一條公告的 `id` 被廢棄或關閉時（`enable: false`），系統偵測到會主動調用 `clearPlayerData` 擦除用戶手機裡的對應緩存，釋放手機空間。因此，**若要對同一個公告重新計數，只需在 JSON 中微調其 `id` 名稱即可**。
2. **HTML 適配**：遠端 HTML 網頁內容在設計時，建議內置圖片與容器加上 `max-width: 100%; height: auto;` 的 CSS 樣式，以完美配合佈局層的自適應寬高縮放。
3. **強制公告的使用**：發佈 `force: true` 的強更或維護公告時，務必確保 `action_type` 設定正確且對應的跳轉功能正常（或 HTML 內部有提供聯絡客服等管道），否則用戶將因無法關閉彈窗而停留在該畫面。

```

```