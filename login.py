# -*- coding:utf-8 -*-
# !/Library/Frameworks/Python.framework/Versions/2.7/bin/python
from __future__ import unicode_literals
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

path = "/usr/local/bin/chromedriver.exe"  # chromedriver完整路径，path是重点
driver = webdriver.Chrome(path)
base_url = 'http://xxx.xxxx.xxx.com'
driver.get(base_url)
wait = WebDriverWait(driver, 20)
wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "#Username"))).send_keys("**********")
wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR, "#password"))).send_keys("**********")
wait.until(EC.visibility_of_element_located((By.CSS_SELECTOR,"#btn"))).click()
wait.until(EC.title_contains("xxx公司统一登录平台"))
driver.get("http://www.sina.cn")
wait.until(EC.title_contains("手机新浪网"))
driver.quit()
