import logging
import pandas as pd
from pathlib import Path

logger = logging.getLogger(__name__)

def extract_excel(path: str, sheet_name=0) -> pd.DataFrame:
    path = Path(path)

    if not path.exists():
        raise FileNotFoundError(f"File not found: {path}")

    if path.suffix.lower() not in (".xls", ".xlsx"): 
        raise ValueError(f"Unsupported file format: {path.suffix}")

    try:
        df = pd.read_excel(path, sheet_name=sheet_name)
        logger.info(f"Successfully read {path.name}, shhet={sheet_name}")
        return df 

    except Exception as e:
        logger.error(f"Failed to read Excel file {path.name}: {e}")
        raise