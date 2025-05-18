# Google Hacking Essentials

As a security researcher, one of the most powerful tools in your reconnaissance arsenal is the ability to leverage search engines to uncover sensitive information, misconfigurations, and potential vulnerabilities. Coined by Johnny Long in 2001, "Google Hacking" (also known as Google Dorking) involves crafting precise search queries using advanced operators to extract valuable data from public-facing systems. In this blog, we'll dive into Google Hacking and explore how to use search operators effectively, avoid common pitfalls, and apply these techniques during security assessments.

## What is Google Hacking?

Google Hacking uses advanced search operators to refine queries and uncover information that organizations may not intend to expose. This can include misconfigured servers, exposed files, directory listings, or even sensitive data like credentials. While the examples here focus on Google, many operators work across other search engines like Bing or DuckDuckGo. The process is iterative: start broad, refine with operators, and analyze results for actionable insights.

Note: Always conduct Google Hacking within the scope of authorized penetration testing engagements. Unauthorized access to systems or data is illegal and unethical.

## Basic Search Operators

For beginners, understanding Google’s search operators is the foundation of effective dorking. These operators allow you to narrow down results to specific domains, file types, or keywords.

### 1. The `site`: Operator

The `site:` operator restricts search results to a specific domain or subdomain. This is useful for mapping an organization’s web presence during reconnaissance.

```
site:example.com
```

This query returns all indexed pages for `example.com`. For a penetration test, this helps you understand the target’s web footprint, including subdomains or forgotten microsites.

![](assets/images/1.png)

### 2. The `filetype:` Operator

The `filetype:` (or `ext:`) operator filters results to specific file extensions, such as `pdf`, `txt`, or `php`. This is particularly useful for finding exposed configuration files or sensitive documents.

Example:

```
site:example.com filetype:pdf
```

This query finds all PDF files indexed on `example.com`. PDFs often contain sensitive information like employee handbooks, network diagrams, or financial reports.

![](assets/images/2.png)

We received an interesting result. Our query found the robots.txt file, containing the following content.

![](assets/images/3.png)

The robots.txt file instructs web crawlers, such as Google’s search engine crawler, to allow or disallow specific resources. In this case, it revealed a specific PHP page (/nanities.php) that was otherwise hidden from the regular search, despite being listed as allowed by the policy.
