"""CP1 — Structured logging.

`print("client abc hỏi gì đó")` là log cho người đọc. Cloud (Railway, Render,
Cloud Run, Datadog...) đọc log bằng máy: một dòng = một JSON object thì mới
lọc/đếm/cảnh báo được. Đây là khác biệt lớn giữa localhost và production.
"""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone


def utc_now_iso() -> str:
    """CHO SẴN — thời điểm hiện tại theo ISO-8601, múi giờ UTC."""
    return datetime.now(timezone.utc).isoformat()


def emit(event: str, severity: str = "INFO", **fields) -> str:
    log_entry = {
        "event": event,
        "severity": severity.upper(),
        "ts": utc_now_iso(),
    }
    log_entry.update(fields)

    line = json.dumps(log_entry, ensure_ascii=False)
    print(line, file=sys.stdout)
    sys.stdout.flush()
    return line
