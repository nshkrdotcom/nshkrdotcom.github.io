#!/usr/bin/env python3
"""Build the site and check math, section pages, embeds, currency, and code."""

import argparse
from html.parser import HTMLParser
from pathlib import Path
import shutil
import subprocess
import tempfile


class MathPage(HTMLParser):
    def __init__(self, path):
        super().__init__()
        self.expressions = []
        self.styles = []
        self.text = []
        self.in_annotation = False
        self.feed(path.read_text())

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "annotation" and attrs.get("encoding") == "application/x-tex":
            self.in_annotation = True
            self.expressions.append("")
        if tag == "link" and attrs.get("rel") == "stylesheet":
            self.styles.append(attrs.get("href", ""))

    def handle_endtag(self, tag):
        if tag == "annotation":
            self.in_annotation = False

    def handle_data(self, data):
        self.text.append(data)
        if self.in_annotation:
            self.expressions[-1] += data


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--hugo", default="hugo")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="nshkr-math-test-") as tmp:
        tmp = Path(tmp)
        content = tmp / "content"
        output = tmp / "public"
        shutil.copytree(root / "content", content)
        fixture = content / "math-regression"
        fixture.mkdir()
        (fixture / "_index.md").write_text(r'''---
title: Math regression section
---
Inline $x_i < y_i$ and \(\alpha_1\).

$$R(a,t+1) = R(a,t) + \beta$$

\[\frac{a_1}{b_2}\]

Currency: &#36;3M - &#36;5M.

`$code_only$`

```sh
echo "$shell_only"
```
''')
        (content / "math-regression-embed.md").write_text('''---
title: Embedded math
---
{{< include-section "math-regression" >}}
''')
        subprocess.run(
            [args.hugo, "--minify", "--contentDir", str(content),
             "--destination", str(output)], cwd=root, check=True,
        )
        pages = {str(p.relative_to(output)): MathPage(p)
                 for p in output.rglob("*.html")}
        math_pages = {path: page for path, page in pages.items() if page.expressions}
        assert len(math_pages) >= 17, sorted(math_pages)
        for path, page in math_pages.items():
            assert any("katex@" in s for s in page.styles), f"Missing math CSS: {path}"
            assert "katex-error" not in (output / path).read_text(), path

        whitepaper = pages["chronoledger/whitepaper/index.html"]
        assert len(whitepaper.expressions) == 11, whitepaper.expressions
        assert r"Accuracy(a, t) = 1 - \frac{|T_{node}(a, t) - T_{consensus}(t)|}{ToleranceWindow(t)}" in whitepaper.expressions
        assert r"W_{faulty} < \frac{1}{3} W_{total}" in whitepaper.expressions
        for path in ("math-regression/index.html", "math-regression-embed/index.html"):
            page = pages[path]
            assert page.expressions == ["x_i < y_i", r"\alpha_1",
                                        r"R(a,t+1) = R(a,t) + \beta", r"\frac{a_1}{b_2}"], page.expressions
            text = "".join(page.text)
            assert "$3M - $5M" in text, text
            assert "$code_only$" in text and "$shell_only" in text
        vc = pages["chronoledger/vc/index.html"]
        assert not vc.expressions, vc.expressions
        assert "$3M - $5M" in "".join(vc.text)
        assert not pages["index.html"].expressions
        print(f"Math rendering passed: {len(math_pages) - 2} existing pages plus section and embed fixtures.")


if __name__ == "__main__":
    main()
