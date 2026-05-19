from pathlib import Path
from urllib.request import urlretrieve

import pandas as pd


ROOT = Path(__file__).resolve().parents[3]
PAPER_DIR = ROOT / "paper_reproductions" / "chan_2022_asymmetric_conjugate_bvar"
AUTHOR_DIR = PAPER_DIR / "data" / "raw" / "author_code" / "BVAR_ACP_R1_code"
FRED_DIR = PAPER_DIR / "data" / "raw" / "fred"
PROCESSED_DIR = PAPER_DIR / "data" / "processed"

FRED_DIR.mkdir(parents=True, exist_ok=True)
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)


def download_fred(series_id: str) -> None:
    url = f"https://fred.stlouisfed.org/graph/fredgraph.csv?id={series_id}"
    dest = FRED_DIR / f"{series_id}.csv"
    urlretrieve(url, dest)


def main() -> None:
    xlsx = AUTHOR_DIR / "database_2019Q4.xlsx"
    raw = pd.read_excel(xlsx, header=None)
    names = [
        "quarter",
        "gdp",
        "gdp_deflator",
        "tbill_3m",
        "investment",
        "sp500",
        "spread_baa_fedfunds",
        "spread_baa_10y",
        "credit_real_estate_ratio",
        "mortgage_rate",
        "cpi",
        "pce",
        "employment",
        "industrial_production",
        "treasury_1y",
        "djia",
    ]
    data = raw.iloc[2:].copy()
    data.columns = names
    data = data.reset_index(drop=True)
    data.to_csv(PROCESSED_DIR / "author_database_1985q1_2019q4.csv", index=False)

    data.iloc[:, :7].to_csv(PROCESSED_DIR / "author_database_6var_1985q1_2019q4.csv", index=False)
    data.to_csv(PROCESSED_DIR / "author_database_15var_1985q1_2019q4.csv", index=False)

    # Public FRED series used to document and approximate the source data.
    # The author workbook remains the table-matching replication source.
    fred_series = [
        "TB3MS",
        "GPDIC1",
        "BAA",
        "FEDFUNDS",
        "GS10",
        "MORTGAGE30US",
        "CPIAUCSL",
        "PCEPI",
        "CE16OV",
        "INDPRO",
        "GS1",
        "DJIA",
    ]
    for series_id in fred_series:
        download_fred(series_id)

    summary = pd.DataFrame(
        {
            "dataset": ["author_6var", "author_15var"],
            "rows": [len(data), len(data)],
            "first_quarter": [data["quarter"].iloc[0], data["quarter"].iloc[0]],
            "last_quarter": [data["quarter"].iloc[-1], data["quarter"].iloc[-1]],
            "variables": [6, 15],
        }
    )
    summary.to_csv(PROCESSED_DIR / "data_summary.csv", index=False)
    print(summary)


if __name__ == "__main__":
    main()
