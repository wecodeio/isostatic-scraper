# Isostatic::Scraper

bearing-solutions.isostatic.com item information scraper

## Installation

Install it yourself as:

    $ gem install isostatic-scraper

## Usage

* Ask for help

```bash
isostatic-scraper --help
```

* Choose where to put the resulting CSV files

```bash
isostatic-scraper --output-dir ~/Desktop ~/Desktop/ISOSTATIC.CAT.CSV
```

* Specify the # of threads to use (defaults to 100)

```bash
isostatic-scraper --threads 50 ~/Desktop/ISOSTATIC.CAT.CSV
```

## Contributing

1. Fork it ( http://github.com/wecodeio/isostatic-scraper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
