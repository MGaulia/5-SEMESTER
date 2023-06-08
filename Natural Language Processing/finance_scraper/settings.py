# -*- coding: utf-8 -*-

# Scrapy settings for finance_scraper project

BOT_NAME = 'finance_scraper'

SPIDER_MODULES = ['finance_scraper.spiders']
NEWSPIDER_MODULE = 'finance_scraper.spiders'

LOG_LEVEL='DEBUG'


# Obey robots.txt rules
ROBOTSTXT_OBEY = True


REACTOR_THREADPOOL_MAXSIZE = 128
CONCURRENT_REQUESTS = 256
CONCURRENT_REQUESTS_PER_DOMAIN = 256
CONCURRENT_REQUESTS_PER_IP = 256

AUTOTHROTTLE_ENABLED = True
AUTOTHROTTLE_START_DELAY = 1
AUTOTHROTTLE_MAX_DELAY = 0.25
AUTOTHROTTLE_TARGET_CONCURRENCY = 128
AUTOTHROTTLE_DEBUG = True


FEED_EXPORTERS = {
    'csv': 'finance_scraper.exporters.CsvCustomSeperator'
}

USER_AGENT='my personal'

