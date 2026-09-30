# JPlag Report Viewer (6.3.0)

**Viewer:** https://cs-education.github.io/jplag-viewer/

This hosts the JPlag report viewer for JPlag **6.3.0** so that `.jplag` reports
filed as academic-integrity evidence can be opened by faculty, staff, and
students. The public viewer at jplag.github.io tracks a different JPlag version
and may not open these reports correctly.

## Viewing a report

1. Download the `results.jplag` file attached to the case report.
2. Open the viewer link above.
3. Drag the file onto the page, or click to choose it.

The report is opened **entirely in your browser**. The file is not uploaded
anywhere, and this site stores no student data.

Click a row under *Top Comparisons* to see the matching code side by side.

## Verifying the evidence file

Each case report lists the SHA-256 hash of its `results.jplag`. To confirm your
copy is the file that was filed:

- Linux: `sha256sum results.jplag`
- macOS: `shasum -a 256 results.jplag`
- Windows (PowerShell): `Get-FileHash results.jplag`

The printed hash should match the one in the report exactly.

## Maintenance

`docs/` is generated. It is the viewer bundled inside the JPlag jar, patched to
run from the `/jplag-viewer/` subpath. To rebuild it for another JPlag release:

```sh
./build.sh path/to/jplag-X.Y.Z-jar-with-dependencies.jar /jplag-viewer/
```

Use `/` as the base path when serving from the root of a domain. The script
stops with an error if a new release changes the bundle layout it patches.

GitHub Pages settings: deploy from branch `main`, folder `/docs`.
