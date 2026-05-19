from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / "paper_reproductions" / "selected_next_10_core_papers"


def download(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists() and dest.stat().st_size > 0:
        return
    print(f"Downloading {url}")
    req = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urlopen(req, timeout=20) as response:
            dest.write_bytes(response.read())
    except (HTTPError, URLError) as exc:
        failures = BASE / "data/raw/DOWNLOAD_FAILURES.md"
        with failures.open("a", encoding="utf-8") as fh:
            fh.write(f"- {url} -> {exc}\n")
        print(f"Warning: failed to download {url}: {exc}")


def download_first_available(urls: list[str], dest: Path) -> None:
    if dest.exists() and dest.stat().st_size > 0:
        return
    for url in urls:
        download(url, dest)
        if dest.exists() and dest.stat().st_size > 0:
            return


def write_text(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def main() -> None:
    failures = BASE / "data/raw/DOWNLOAD_FAILURES.md"
    if failures.exists():
        failures.unlink()

    fred_md_url = "https://www.stlouisfed.org/-/media/project/frbstl/stlouisfed/research/fred-md/monthly/2026-04-md.csv"
    fred_qd_url = "https://www.stlouisfed.org/-/media/project/frbstl/stlouisfed/research/fred-md/quarterly/2026-04-qd.csv"

    download(fred_md_url, BASE / "data/raw/fred_md/2026-04-md.csv")
    download(fred_qd_url, BASE / "data/raw/fred_qd/2026-04-qd.csv")

    fred_series = [
        "GDPC1",
        "GDPCTPI",
        "UNRATE",
        "TB3MS",
        "FEDFUNDS",
        "CPIAUCSL",
        "INDPRO",
        "PAYEMS",
        "GS10",
        "M2SL",
        "PCEPI",
        "CE16OV",
    ]
    for series in fred_series:
        download(
            f"https://fred.stlouisfed.org/graph/fredgraph.csv?id={series}",
            BASE / f"data/raw/fred_series/{series}.csv",
        )

    download(
        "https://dataverse.harvard.edu/api/access/datafile/11572802",
        BASE / "giannone_lenza_primiceri_2015_prior_selection/data/raw/GLPreplicationWeb.zip",
    )
    download(
        "http://qed.econ.queensu.ca/jae/1997-v12.2/kadiyala-karlsson/readme.kk.txt",
        BASE / "kadiyala_karlsson_1997_bvar_numerical/data/raw/readme.kk.txt",
    )
    download(
        "http://qed.econ.queensu.ca/jae/1997-v12.2/kadiyala-karlsson/data.zip",
        BASE / "kadiyala_karlsson_1997_bvar_numerical/data/raw/data.zip",
    )
    download(
        "http://qed.econ.queensu.ca/jae/1997-v12.2/kadiyala-karlsson/var.zip",
        BASE / "kadiyala_karlsson_1997_bvar_numerical/data/raw/var.zip",
    )

    download(
        "https://www.minneapolisfed.org/research/wp/wp274.pdf",
        BASE / "litterman_1986_bvar_forecasting/paper/wp274_litterman_1986.pdf",
    )
    download(
        "https://www.federalreserve.gov/pubs/feds/2004/200403/200403pap.pdf",
        BASE / "bernanke_boivin_eliasz_2005_favar/paper/feds_2004_03_favar.pdf",
    )
    download_first_available(
        [
            "https://www.princeton.edu/~mwatson/papers/Stock_Watson_JBES_2002.pdf",
            "https://scholar.harvard.edu/files/stock/files/macroeconomic_forecasting_using_diffusion_indexes.pdf",
        ],
        BASE / "stock_watson_2002_diffusion_indexes/paper/stock_watson_2002_diffusion_indexes.pdf",
    )

    source_note = """# Downloaded Source Files

Downloaded by `code/download_sources.py`.

## Large Public Macro Panels

- FRED-MD current monthly data: https://www.stlouisfed.org/research/economists/mccracken/fred-databases
- FRED-QD current quarterly data: https://www.stlouisfed.org/research/economists/mccracken/fred-databases

## FRED Single Series

- `GDPC1`: https://fred.stlouisfed.org/series/GDPC1
- `GDPCTPI`: https://fred.stlouisfed.org/series/GDPCTPI
- `UNRATE`: https://fred.stlouisfed.org/series/UNRATE
- `TB3MS`: https://fred.stlouisfed.org/series/TB3MS
- `FEDFUNDS`: https://fred.stlouisfed.org/series/FEDFUNDS
- `CPIAUCSL`: https://fred.stlouisfed.org/series/CPIAUCSL
- `INDPRO`: https://fred.stlouisfed.org/series/INDPRO
- `PAYEMS`: https://fred.stlouisfed.org/series/PAYEMS
- `GS10`: https://fred.stlouisfed.org/series/GS10
- `M2SL`: https://fred.stlouisfed.org/series/M2SL
- `PCEPI`: https://fred.stlouisfed.org/series/PCEPI
- `CE16OV`: https://fred.stlouisfed.org/series/CE16OV

## Paper Archives

- Giannone, Lenza and Primiceri (2015), Harvard Dataverse DOI: https://doi.org/10.7910/DVN/27345
- Kadiyala and Karlsson (1997), JAE archive: http://qed.econ.queensu.ca/jae/1997-v12.2/kadiyala-karlsson/
- Litterman (1986), Minneapolis Fed WP 274: https://www.minneapolisfed.org/research/wp/wp274.pdf
- Bernanke, Boivin and Eliasz (2005), FEDS version: https://www.federalreserve.gov/pubs/feds/2004/200403/200403pap.pdf
- Stock and Watson (2002), author PDF: https://scholar.harvard.edu/files/stock/files/macroeconomic_forecasting_using_diffusion_indexes.pdf
- Stock and Watson (2002), backup PDF: https://www.princeton.edu/~mwatson/papers/Stock_Watson_JBES_2002.pdf
"""
    write_text(BASE / "data/raw/SOURCES.md", source_note)
    print("Source downloads complete.")


if __name__ == "__main__":
    main()
