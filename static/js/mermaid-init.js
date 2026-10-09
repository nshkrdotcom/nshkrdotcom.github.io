// Use CSS tokens so diagrams follow the site's graphite, steel, and stone theme.
if (typeof mermaid !== 'undefined') {
    const palette = getComputedStyle(document.documentElement);
    const color = (name) => palette.getPropertyValue(name).trim();
    // Both Hugo code blocks and older inline diagrams can carry their own colors.
    document.querySelectorAll('.mermaid').forEach((diagram) => {
        diagram.innerHTML = diagram.innerHTML
            .replace(/fill:\s*#[\da-f]{3,8}\b/gi, `fill:${color('--bg2')}`)
            .replace(/stroke:\s*#[\da-f]{3,8}\b/gi, `stroke:${color('--steel')}`)
            .replace(/color:\s*#[\da-f]{3,8}\b/gi, `color:${color('--text')}`)
            .replace(/(['"](?:primaryColor|secondaryColor|tertiaryColor|background)['"]\s*:\s*)['"]#[\da-f]{3,8}['"]/gi, `$1'${color('--bg2')}'`)
            .replace(/(['"](?:primaryTextColor|textColor)['"]\s*:\s*)['"]#[\da-f]{3,8}['"]/gi, `$1'${color('--text')}'`)
            .replace(/(['"]lineColor['"]\s*:\s*)['"]#[\da-f]{3,8}['"]/gi, `$1'${color('--steel')}'`)
            .replace(/(['"]theme['"]\s*:\s*)['"](?:neutral|default|dark)['"]/gi, "$1'base'");
    });
    mermaid.initialize({
        startOnLoad: true,
        theme: 'base',
        securityLevel: 'loose',
        themeVariables: {
            darkMode: true,
            background: color('--bg'),
            primaryColor: color('--bg2'),
            primaryTextColor: color('--text'),
            primaryBorderColor: color('--steel'),
            secondaryColor: color('--bg3'),
            secondaryTextColor: color('--text'),
            secondaryBorderColor: color('--stone'),
            tertiaryColor: color('--bg2'),
            tertiaryTextColor: color('--text'),
            tertiaryBorderColor: color('--border2'),
            lineColor: color('--steel'),
            textColor: color('--text'),
            edgeLabelBackground: color('--bg'),
            clusterBkg: color('--bg2'),
            clusterBorder: color('--border2'),
            actorBkg: color('--bg2'),
            actorBorder: color('--steel'),
            actorTextColor: color('--text'),
            signalColor: color('--text2'),
            signalTextColor: color('--text2'),
            noteBkgColor: color('--bg3'),
            noteTextColor: color('--text'),
            noteBorderColor: color('--stone'),
            fontFamily: palette.getPropertyValue('--font-sans').trim()
        },
        flowchart: { useMaxWidth: true, htmlLabels: true }
    });
}
