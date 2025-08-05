import pandas as pd
from ydata_profiling import ProfileReport

DATA_URL = "https://github.com/mwaskom/seaborn-data/raw/master/diamonds.csv"
DELIMITER = ","
HTML_REPORT_FNAME = "eda_ydata_profiling_diamons.html"
HTML_REPORT_TITLE = "Diamons Ydata Profiling Report"


def main():
    try:
        df = pd.read_csv(DATA_URL, delimiter=DELIMITER)
        report = ProfileReport(df, title=HTML_REPORT_TITLE)
        report.to_file(HTML_REPORT_FNAME)
    except Exception as e:
        raise RuntimeError("Failed to generate profiling report") from e


if __name__ == "__main__":
    main()
