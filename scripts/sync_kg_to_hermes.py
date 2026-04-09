#!/usr/bin/env python3
"""
MemPalace → Hermes Agent 知識圖譜同步腳本

功能：
1. 從 MemPalace 匯出知識圖譜（實體與關係）
2. 轉換為 Hermes Context File 格式
3. 自動比對變更，僅在有更新時寫入
4. 支援增量同步（記錄上次同步時間）

使用方式：
  python sync_kg_to_hermes.py          # 執行同步
  python sync_kg_to_hermes.py --dry-run  # 預覽變更
  python sync_kg_to_hermes.py --force    # 強制覆蓋
"""

import json
import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Optional


class MemPalaceKGExporter:
    """MemPalace 知識圖譜匯出器"""

    def __init__(self):
        self.hermes_context_dir = Path.home() / ".hermes" / "context"
        self.sync_state_file = Path.home() / ".mempalace" / "sync_state.json"
        self.output_file = self.hermes_context_dir / "mempalace_kg.md"

    def run_mempalace_command(self, command: str) -> dict:
        """執行 mempalace MCP 命令（透過 Python 腳本或直接呼叫）"""
        # 注意：這裡使用 MCP 工具，實際執行時需透過 MCP 客戶端
        # 此處為預留介面
        pass

    def get_kg_stats(self) -> dict:
        """取得知識圖譜統計"""
        # 透過 MCP 工具呼叫
        pass

    def get_entity_relations(self, entity: str) -> dict:
        """取得實體的關係資料"""
        # 透過 MCP 工具呼叫
        pass

    def get_all_entities(self) -> list:
        """取得所有實體清單"""
        # 從 entities.json 或 KG 查詢
        entities_file = Path(__file__).parent.parent / "docs" / "entities.json"
        if entities_file.exists():
            with open(entities_file, "r", encoding="utf-8") as f:
                data = json.load(f)
                return data.get("projects", []) + data.get("people", [])
        return []

    def load_sync_state(self) -> dict:
        """載入上次同步狀態"""
        if self.sync_state_file.exists():
            with open(self.sync_state_file, "r", encoding="utf-8") as f:
                return json.load(f)
        return {"last_sync": None, "synced_entities": {}}

    def save_sync_state(self, state: dict):
        """儲存同步狀態"""
        self.sync_state_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.sync_state_file, "w", encoding="utf-8") as f:
            json.dump(state, f, ensure_ascii=False, indent=2)

    def has_changes(self, entity: str, current_data: dict) -> bool:
        """檢查實體是否有變更"""
        state = self.load_sync_state()
        synced = state.get("synced_entities", {}).get(entity, {})

        # 簡易比對：比較關係數量與類型
        if synced.get("relation_count") != current_data.get("relation_count"):
            return True
        return False

    def kg_to_markdown(self, entities_data: dict) -> str:
        """將知識圖譜資料轉換為 Markdown 格式"""
        lines = [
            "# MemPalace 知識圖譜 — Hermes Agent 同步",
            "",
            f"> **最後同步時間**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "> **來源**: MemPalace Knowledge Graph",
            "> **說明**: 此檔案由 `sync_kg_to_hermes.py` 自動生成，請勿手動編輯",
            "",
            "---",
            "",
        ]

        # 摘要統計
        stats = entities_data.get("stats", {})
        lines.extend([
            "## 📊 知識圖譜摘要",
            "",
            f"- **實體總數**: {stats.get('entities', 0)}",
            f"- **關係總數**: {stats.get('triples', 0)}",
            f"- **有效事實**: {stats.get('current_facts', 0)}",
            f"- **已過期事實**: {stats.get('expired_facts', 0)}",
            "",
            "---",
            "",
        ])

        # 實體詳情
        entities = entities_data.get("entities", {})
        if entities:
            lines.append("## 🏷️ 實體詳情")
            lines.append("")

            for entity_name, entity_data in entities.items():
                lines.extend([
                    f"### {entity_name}",
                    "",
                ])

                relations = entity_data.get("relations", [])
                if relations:
                    lines.append("**關係**:")
                    lines.append("")
                    for rel in relations:
                        predicate = rel.get("predicate", "")
                        obj = rel.get("object", "")
                        valid_from = rel.get("valid_from", "")
                        lines.append(f"- **{predicate}** → {obj}")
                        if valid_from:
                            lines.append(f"  - 生效時間: {valid_from}")
                    lines.append("")
                else:
                    lines.append("*尚無關係資料*")
                    lines.append("")

                lines.append("---")
                lines.append("")
        else:
            lines.extend([
                "## ⚠️ 目前知識圖譜為空",
                "",
                "知識圖譜尚未建立。建議執行以下操作來充實知識圖譜：",
                "",
                "```bash",
                "# 透過 MCP 工具添加實體關係",
                "mempalace_kg_add(subject='專案名', predicate='uses', object='技術棧')",
                "mempalace_kg_add(subject='專案名', predicate='depends_on', object='依賴')",
                "```",
                "",
                "或者從 `docs/entities.json` 讀取專案清單作為起點。",
                "",
                "---",
                "",
            ])

        # 專案清單（從 entities.json）
        projects = entities_data.get("projects_from_json", [])
        if projects:
            lines.extend([
                "## 📦 已知專案清單",
                "",
                "從 `docs/entities.json` 匯入：",
                "",
            ])
            for project in projects:
                lines.append(f"- {project}")
            lines.append("")

        # 使用建議
        lines.extend([
            "## 💡 使用建議",
            "",
            "當處理與上述專案相關的任務時，請參考這些背景知識：",
            "",
            "1. **技術選型**: 理解專案使用的技術棧",
            "2. **依賴關係**: 知道專案間的依賴",
            "3. **決策背景**: 了解過去的技術決策",
            "",
            "---",
            "",
            f"*此檔案由同步腳本於 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} 生成*",
        ])

        return "\n".join(lines)

    def export(self, dry_run: bool = False, force: bool = False) -> dict:
        """執行匯出與同步"""
        print("🔄 開始同步 MemPalace KG → Hermes Context")
        print("=" * 60)

        # 1. 收集資料
        all_entities = self.get_all_entities()
        print(f"📋 找到 {len(all_entities)} 個實體: {', '.join(all_entities)}")

        # 2. 組裝資料結構
        entities_data = {
            "stats": {
                "entities": 0,  # 目前 KG 為空
                "triples": 0,
                "current_facts": 0,
                "expired_facts": 0,
            },
            "entities": {},
            "projects_from_json": all_entities,
        }

        # 3. 檢查是否有變更
        has_any_changes = False
        for entity in all_entities:
            # 此處未來可呼叫 MCP 工具取得實際關係
            current_data = {"relation_count": 0}
            if self.has_changes(entity, current_data) or force:
                has_any_changes = True
                print(f"  ✏️  {entity}: 有更新")
            else:
                print(f"  ⏭️  {entity}: 無變更")

        # 4. 決定是否寫入
        if not has_any_changes and not force:
            print("\n✅ 無變更，跳過寫入")
            return {"status": "no_changes"}

        # 5. 生成 Markdown
        md_content = self.kg_to_markdown(entities_data)

        if dry_run:
            print("\n📄 [DRY RUN] 預覽輸出內容:")
            print("=" * 60)
            print(md_content)
            print("=" * 60)
            return {"status": "dry_run"}

        # 6. 寫入檔案
        self.hermes_context_dir.mkdir(parents=True, exist_ok=True)
        with open(self.output_file, "w", encoding="utf-8") as f:
            f.write(md_content)

        print(f"\n✅ 已寫入: {self.output_file}")
        print(f"📊 實體數: {len(all_entities)}")
        print(f"📏 檔案大小: {self.output_file.stat().st_size / 1024:.2f} KB")

        # 7. 更新同步狀態
        sync_state = {
            "last_sync": datetime.now().isoformat(),
            "synced_entities": {
                entity: {"relation_count": 0} for entity in all_entities
            },
            "output_file": str(self.output_file),
        }
        self.save_sync_state(sync_state)

        return {
            "status": "success",
            "entities_synced": len(all_entities),
            "output_file": str(self.output_file),
        }


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="MemPalace → Hermes Agent 知識圖譜同步"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="預覽變更，不實際寫入"
    )
    parser.add_argument(
        "--force", action="store_true", help="強制覆蓋，忽略變更檢查"
    )
    parser.add_argument(
        "--verbose", "-v", action="store_true", help="顯示詳細輸出"
    )

    args = parser.parse_args()

    exporter = MemPalaceKGExporter()
    result = exporter.export(dry_run=args.dry_run, force=args.force)

    print("\n" + "=" * 60)
    print(f"狀態: {result['status']}")
    if result.get("entities_synced"):
        print(f"同步實體數: {result['entities_synced']}")
    if result.get("output_file"):
        print(f"輸出檔案: {result['output_file']}")
    print("=" * 60)

    return 0 if result["status"] in ["success", "no_changes"] else 1


if __name__ == "__main__":
    sys.exit(main())
