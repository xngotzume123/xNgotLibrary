# Docs / Tài liệu

Edit `content.py` and `details.py` for both languages and `template.html` for the interface. To rebuild the self-contained `docs/index.html` and both Markdown manuals:

```bash
python3 -m pip install -r docs/site/requirements.txt
python3 docs/site/build.py
```

The generated HTML has no CDN dependencies and works locally or on GitHub Pages. For Pages, commit the workflow at `.github/workflows/pages.yml`, enable GitHub Actions as the Pages source, and push to `main`. Publishing the docs does not update `dist/main.lua` on GitHub by itself.
