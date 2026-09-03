import logging
from pathlib import Path 
import pandas as pd 

logger = logging.getLogger(__name__)

def extract_csv(path: str) -> pd.DataFrame:
    path = Path(path)

    if not path.exists():
        raise FileNotFoundError(f"File not found: {path}")

    for encoding in ("utf-8", "cp1251", "latin1"):
        try:
            df = pd.read_csv(path, sep=',', encoding=encoding, quotechar='"', engine="python")
            return df 
        except UnicodeDecodeError
            logger.warning(f"Failed encoding {encoding} for {parh.name}")
    
    raise ValueError(f"Cannot decode file {path.name} with any of the tried encodings")