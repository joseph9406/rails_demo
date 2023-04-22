# -*- coding: utf-8 -*-
# (c) 2015, 2016 Daniel Lobato <elobatocs@gmail.com>
# (c) 2016 Guido Günther <agx@sigxcpu.org>
# (c) 2017 Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# pylint: disable=super-with-arguments
"""
from __future__ import (absolute_import, division, print_function) 說明如下;
from __future__ import ... 將新版本的特性,引進到當前的版本中,也就是說,我們可以在當前的版本,使用新版本的一些特性。

absolute_import;
針對python 2.4及之前的版本,這些版本在引入某一個py文件時, 會優先引用當前目錄下的的文件。
在 Python 2 中, 当导入一个模块时, Python 会首先在当前目录搜索同名的模块，如果没有找到才会去搜索标准库路径中的模块。
这样可能会导致模块名冲突的问题，因为我们可能会在当前目录中定义与标准库同名的模块。
为了解决这个问题, Python 2.5 引入了 absolute_import 特性。
当使用 from __future__ import absolute_import 语句时, Python 会优先从系统路径中导入模块，而不再从当前目录中导入同名模块。

例如，假设我们有一个名为 string 的模块，在当前目录中定义了一个名为 string.py 的文件。
在没有启用 absolute_import 特性的情况下，我们在另一个脚本中导入标准库中的 string 模块时，
实际上导入的是当前目录下的 string.py 文件。但如果我们在脚本开头加上 from __future__ import absolute_import，
则导入标准库中的 string 模块时会优先从系统路径中查找，不会再从当前目录中导入同名模块。

启用 absolute_import 特性还可以让我们更清楚地表明导入的是标准库中的模块，而不是同名的局部模块。

print_function;
可以将 print 语句转换为 print() 函数。在 Python 2 中, print 是一个语句而不是一个函数，因此它不能像函数一样传递参数和关键字参数。
但在 Python 3 中, print 被转换为一个函数，可以像其他函数一样进行调用。
启用 print_function 特性可以让 Python 2 中的 print 行为和 Python 3 中的 print 行为一致，从而使代码更易于移植和兼容。
"""

from __future__ import (absolute_import, division, print_function)

# 在 Python 3 中，类的定义方式已经改变，使用新式类（new-style class）的创建方式。
#  因此，默认使用 type 元类，不需要显式指定 __metaclass__ 属性。
__metaclass__ = type 

DOCUMENTATION = '''
    callback: theforeman.foreman.foreman
    type: notification
    short_description: Sends events to Foreman
    description:
      - This callback will report facts and task events to Foreman
    requirements:
      - whitelisting in configuration
      - requests (python library)
    options:
      url:
        description:
          - URL of the Foreman server.
        env:
          - name: FOREMAN_URL
          - name: FOREMAN_SERVER_URL
          - name: FOREMAN_SERVER
        required: True
        default: http://localhost:3000
        ini:
          - section: callback_foreman
            key: url
      client_cert:
        description:
          - X509 certificate to authenticate to Foreman if https is used 
        env:
            - name: FOREMAN_SSL_CERT
        default: /etc/foreman/client_cert.pem
        ini:
          - section: callback_foreman
            key: ssl_cert
          - section: callback_foreman
            key: client_cert
        aliases: [ ssl_cert ]
      client_key:
        description:
          - the corresponding private key
        env:
          - name: FOREMAN_SSL_KEY
        default: /etc/foreman/client_key.pem
        ini:
          - section: callback_foreman
            key: ssl_cert
          - section: callback_foreman
            key: client_cert
        aliases: [ ssl_cert ]
      client_key:
        description:
          - the corresponding private key
        env:
          - name: FOREMAN_SSL_KEY
        default: /etc/foreman/client_key.pem
        ini:
          - section: callback_foreman
            key: ssl_key
          - section: callback_foreman
            key: client_key
        aliases: [ ssl_key ]
      verify_certs:
        description:
          - Toggle to decide whether to verify the Foreman certificate.
          - It can be set to '1' to verify SSL certificates using the installed CAs or to a path pointing to a CA bundle.
          - Set to '0' to disable certificate checking.
        env:
          - name: FOREMAN_SSL_VERIFY
        default: 1
        ini:
          - section: callback_foreman
            key: verify_certs
      dir_store:
        description:
          - When set, callback does not perform HTTP calls but stores results in a given directory.
          - For each report, new file in the form of SEQ_NO-hostname.json is created.
          - For each facts,  new file in the form of SEQ_NO-hostname.json is created.
          - The value must be a valid directory.
          - This is meant for debugging and testing purposes.
          - When set to blank (default) this functionality is turned off.
        env:
          - name: FOREMAN_DIR_STORE
        default: ''
        ini:
          - section: callback_foreman
            key: dir_store
      disable_callback:
        description:
          - Toggle to make the callback plugin disable itself even if it is loaded.
          - It can be set to '1' to prevent the plugin from being used even if it gets loaded.
        env:
          - name: FOREMAN_CALLBACK_DISABLE
       default: 0
'''

import os
from datetime import datetime
from collections import defaultdict
import json
import time

try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    HAS_REQUESTS = False

# 该函数用于将给定的字符串转换为 Unicode 编码，并且可以处理不同的字符集和编码方式，确保字符串的正确性和可读性。
from ansible.module_utils._text import to_text
# boolean 函数用于将字符串转换为布尔值。例如，字符串 "yes"、"true"、"on" 都会被转换为 True，而字符串 "no"、"false"、"off" 都会被转换为 False。
from ansible.module_utils.parsing.convert_bool import boolean as to_bool
# CallbackBase类是 Ansible 插件的基类，可以作为其它自定义插件的基础。通过继承 CallbackBase 类以实现其中的回调函数，可以实现对 Ansible 执行过程中各种事件的监听和处理。
from ansible.plugins.callback import CallbackBase
   

def build_log(data):    
    # Transform the internal log structure to one accepted by Foreman's config_report API.    
    for source, msg in data:
        #有兩種方式以获取字典里的值,一个是通过键值对，即dict['key'],另一个就是dict.get()方法。
        # 但是若字典中找不到 key 时, msg["changed"] 會引发 KeyError 异常，然而 msg.get("changed") 则会返回 None，而不是引发异常。
        # 因此，如果你确定字典中一定有 key "changed"，可以使用 msg["changed"]，否则建议使用 msg.get("changed") 来避免出现异常。
        if msg.get('failed'):  
            level = 'err'
        elif msg.get('changed'):
            level = 'notice'
        else:
            level = 'info'

        # yield 语句会暂停函数的执行, 并返回一个值给调用者。当下一次调用生成器函数时，它会从上次离开的地方继续执行，直到再次遇到一个 yield 语句。
        yield {
            "log": {
                'sources': {'source': source,},
                'messages': {'message': json.dumps(msg, sort_keys=True), },  # 将python对象转换为json字符串              
                'level': level,
            }
        }

def get_time():
    """
    Return the time for measuring duration. Prefers monotonic time but
    falls back to the regular time on older Python versions.
    """
    try:
        return time.monotonic()
    except AttributeError:
        return time.time()

def get_now():
    """
    Return the current timestamp as a string to be sent over the network.
    """
    return datetime.utcnow().isoformat()


class CallbackModule(CallbackBase):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'notification'
    CALLBACK_NAME = 'theforeman.foreman.foreman'  #回调名称很重要，在配置文件中启用回调时，必须使用 CALLBACK_NAME。如果名称不匹配，回调将无法正常工作。
    CALLBACK_NEEDS_WHITELIST = True

    def __init__(self):	    
        super(CallbackModule, self).__init__()   #Python3.x 和 Python2.x 的区别是: Python3 可以使用 super().xxx 代替 super(Class, self).xxx :
        # defaultdict的作用是在于，当字典里被查找某指定key值不存在時,將會返回一個默認值。
        # 若沒有此處理,則會直接報錯keyError。这个默认值是什么呢? 
        # 就是以defaultdict(xxx)裏的"xxx"的默認值來做為該key的默認值
        self.items = defaultdict(list)  # 创建一个新的字典,其默认值是[],因為list的默認值是[]。
        self.facts = defaultdict(dict)  # 创建一个新的字典,默認值是{}。
        self.start_time = get_time()

    def set_options(self, task_keys=None, var_options=None, direct=None):

        super(CallbackModule, self).set_options(task_keys=task_keys, var_options=var_options, direct=direct)

        # get_option("xxx") 的作用是从 Ansible 配置文件(/etc/ansible/ansible.cfg）或者命令行参数中获取指定选项的值。
        if self.get_option('disable_callback'):
            self._disable_plugin('Callback disabled by environment.')

        self.foreman_url = self.get_option('url')
        ssl_cert = self.get_option('client_cert')
        ssl_key = self.get_option('client_key')
        self.dir_store = self.get_option('dir_store')

        if not HAS_REQUESTS:
            # 在Python2中，字符串前面加u表示该字符串是一个Unicode字符串。但在Python3中，已经不再需要使用u前缀来表示Unicode字符串，因为字符串默认就是Unicode编码的。
            self._disable_plugin(u'The `requests` python module is not installed')

        self.session = requests.Session()

        if self.foreman_url.startswith('https://'):
            if not os.path.exists(ssl_cert):
                self._disable_plugin(u'FOREMAN_SSL_CERT %s not found.' % ssl_cert)

            if not os.path.exists(ssl_key):
                self._disable_plugin(u'FOREMAN_SSL_KEY %s not found.' % ssl_key)

            self.session.verify = self._ssl_verify(str(self.get_option('verify_certs')))
            self.session.cert = (ssl_cert, ssl_key)

    def _disable_plugin(self, msg):       
        # _display 对象通常是一个记录器（logger），用于输出各种级别的日志信息; warning() 方法是记录器对象的一个方法，用于输出警告级别的日志消息。       
        self.disabled = True
        if msg:
            self._display.warning(msg + u' Disabling the Foreman callback plugin.')
        else:
            self._display.warning(u'Disabling the Foreman callback plugin.')


    def _ssl_verify(self, option):
        try:
            verify = to_bool(option)
        except TypeError:
            verify = option

        # 只需要在请求的时候加上 verify=False 即可，这个参数的意思是忽略https安全证书的验证
        # 在urllib3时代，官方强制验证https的安全证书，如果没有通过是不能通过请求的，
        # 虽然添加忽略验证的参数，但是依然会给出醒目的 Warning, 所以若要禁用該警告,就要使用disable_warnings()
        if verify is False:  # is only set to bool if try block succeeds
            requests.packages.urllib3.disable_warnings()
            self._display.warning(u"SSL verification of %s disabled" % self.foreman_url,)
        return verify

    def _send_data(self, endpoint, host, data):
        if endpoint == 'facts':
            url = self.foreman_url + '/api/v2/hosts/facts'
        elif endpoint == 'report':
            url = self.foreman_url + '/api/v2/config_reports'
        else:
            # 前綴u表示字符串以 Unicode 格式 进行编码，一般用在中文字符串前面，防止因为源码储存格式问题，导致再次使用时出现乱码,在python2中使用
            # Python3中，所有字符串默认都是unicode字符串。
            # 前綴r表示該字符串是原始字符串，即\不是转义符，只是单纯的一个符号。
            self._display.warning(u'Unknown endpoint type: {type}'.format(type=endpoint))

        if len(self.dir_store) > 0:
            filename = u'{host}.json'.format(host=to_text(host))
            filename = os.path.join(self.dir_store, filename)

            # 使用 open() 函數打開一個文件，並將文件對象賦值給變數 f。'w' 表示以寫入模式打開文件，如果該文件不存在，則會被創建。
            # 使用 with 語句，可以確保在寫入文件結束後，文件自動關閉。
            with open(filename, 'w') as f:    
                json.dump(data, f, indent=2, sort_keys=True)  # 用於將 Python 對象 data 寫入到 JSON 文件中, 並將縮進大小設置為 2，按照鍵名排序。
        else:
            try:
                '''
                1. 使用名为"session"的对象来发送一个POST请求到指定的URL, 并将数据以JSON格式发送。
                2. 使用 response.raise_for_status() 檢查響應狀態碼，如果響應狀態碼表明請求失敗（即不是 200 OK), 則該方法會引發一個異常，以指示請求失敗。
                   例如, 如果狀態碼為 404, 表示該網站上沒有找到我們要求的頁面，
                   那麼 response.raise_for_status() 將引發一個 HTTPError 異常，以指示請求失敗。
                '''
                response = self.session.post(url=url, json=data)  
                response.raise_for_status()  #
            except requests.exceptions.RequestException as err:
                self._display.warning(u'Sending data to Foreman at {url} failed for {host}: {err}'.format(
                    host=to_text(host), err=to_text(err), url=to_text(self.foreman_url)))

    def send_facts(self):
        """
        Sends facts to Foreman, to be parsed by foreman_ansible fact
        parser.  The default fact importer should import these facts
        properly.
        """
        
        for host, facts in self.facts.items():
            facts = {
                "name": host,
                "facts": {
                    "ansible_facts": self.facts[host],
                    "_type": "ansible",
                    "_timestamp": get_now(),
                },
            }

            self._send_data('facts', host, facts)

    def send_reports(self, stats):
        """
        Send reports to Foreman to be parsed by its config report
        importer. THe data is in a format that Foreman can handle
        without writing another report importer.
        """
        for host in stats.processed.keys():
            total = stats.summarize(host)
            report = {
                "config_report": {
                    "host": host,
                    "reported_at": get_now(),
                    "metrics": {
                        "time": {
                            "total": int(get_time() - self.start_time)
                        }
                    },
                    "status": {
                        "applied": total['changed'],
                        "failed": total['failures'] + total['unreachable'],
                        "skipped": total['skipped'],
                    },
                    "logs": list(build_log(self.items[host])),
                    "reporter": "ansible",
                    "check_mode": self.check_mode,
                }
            }  
            if self.check_mode:
                report['config_report']['status']['pending'] = total['changed']
                report['config_report']['status']['applied'] = 0

            self._send_data('report', host, report)

            self.items[host] = []

    def append_result(self, result, failed=False):
        name = result._task.get_name()
        host = result._host.get_name()
        value = result._result  # result._result: 這個任務返回的結果，通常是一個字典。
        value['failed'] = failed
        value['module'] = result._task.action
        self.items[host].append((name, value))
        self.check_mode = result._task.check_mode
        if 'ansible_facts' in value:
            self.facts[host].update(value['ansible_facts'])

    """
    Ansible callback API
    以下函數所包含的參數 result 是一個 Ansible 的 TaskResult 對象，它包含了任務執行的相關資訊，包括：
    result._task: 這個任務的 Task 對象。
    result._result: 這個任務返回的結果，通常是一個字典。
    result._host: 這個任務執行的目標主機。    
    result._task_fields: 這個任務的其他相關資訊，例如任務的名稱、描述等等。
    """

    def v2_runner_on_failed(self, result, ignore_errors=False):
        self.append_result(result, True)

    def v2_runner_on_unreachable(self, result):
        self.append_result(result, True)

    def v2_runner_on_async_ok(self, result):
        self.append_result(result)

    def v2_runner_on_async_failed(self, result):
        self.append_result(result, True)

    # 当 playbook 执行完毕后(不論成功或失敗,都會執行)，Ansible 会生成一个包含 playbook 执行统计信息的 stats 对象，并将其作为参数传递给这个方法。
    # 在这个方法中，可以使用 stats 参数来分析 playbook 的执行结果，并对 playbook 的执行效果进行评估和分析。
    def v2_playbook_on_stats(self, stats):  
        self.send_facts()
        self.send_reports(stats)

    def v2_runner_on_ok(self, result):
        self.append_result(result)