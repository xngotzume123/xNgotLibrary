"""Extract the real control-routing source and run deterministic Luau mocks.

Run with LUAU=/path/to/luau python3 tests/test_ai_assistant.py.
These mocks do not replace Roblox integration testing.
"""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]

class AIAssistantTests(unittest.TestCase):
    def run_luau(self, name, marker, source):
        binary = os.environ.get('LUAU')
        if not binary:
            self.skipTest('Set LUAU to a Luau executable')
        harness = (ROOT / 'tests' / name).read_text()
        assert harness.count(marker) == 1
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'test.luau'
            path.write_text(harness.replace(marker, source))
            subprocess.run([binary, str(path)], check=True)

    def test_confirmation_and_control_routing(self):
        text = (ROOT / 'src/modules/30_overlay/148_cross_control.lua').read_text()
        norm = text[text.index('local function __askNorm'):text.index('local function __has')]
        routing = text[text.index('local __crossAskBase = Cross.ask'):text.index('\ndo\n    local previousExpand = Isl.expand')]
        self.run_luau('ai_assistant_harness.luau', '-- __INSERT_AI_CODE__', norm + routing)

    def test_teaching_and_confirmations_together(self):
        learning = (ROOT / 'src/modules/30_overlay/146_cross_learning.lua').read_text()
        text = (ROOT / 'src/modules/30_overlay/148_cross_control.lua').read_text()
        norm = text[text.index('local function __askNorm'):text.index('local function __has')]
        routing = text[text.index('local __crossAskBase = Cross.ask'):text.index('\ndo\n    local previousExpand = Isl.expand')]
        harness = (ROOT / 'tests/ai_learning_integration_harness.luau').read_text()
        learning_code = learning[learning.index('do\n    local maxAliases'):]
        harness = harness.replace('-- __INSERT_LEARNING_CODE__', learning_code)
        self.run_luau_text(harness.replace('-- __INSERT_AI_CODE__', norm + routing))

    def run_luau_text(self, code):
        binary = os.environ.get('LUAU')
        if not binary:
            self.skipTest('Set LUAU to a Luau executable')
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'test.luau'
            path.write_text(code)
            subprocess.run([binary, str(path)], check=True)

    def test_per_user_learning_storage(self):
        text = (ROOT / 'src/modules/30_overlay/146_cross_learning.lua').read_text()
        code = text[text.index('do\n    local maxAliases'):]
        self.run_luau('ai_learning_storage_harness.luau', '-- __INSERT_LEARNING_CODE__', code)

    def test_no_learning_settings_ui(self):
        text = (ROOT / 'src/modules/40_window/330_island_tab.lua').read_text()
        self.assertNotIn('Cross AI Learning', text)
        self.assertNotIn('Teach Cross AI', text)
        self.assertNotIn('Start remembering preferences', text)

    def test_automatic_learning_and_confirmation(self):
        learning = (ROOT / 'src/modules/30_overlay/146_cross_learning.lua').read_text()
        text = (ROOT / 'src/modules/30_overlay/148_cross_control.lua').read_text()
        norm = text[text.index('local function __askNorm'):text.index('local function __has')]
        routing = text[text.index('local __crossAskBase = Cross.ask'):text.index('\ndo\n    local previousExpand = Isl.expand')]
        harness = (ROOT / 'tests/ai_auto_learning_harness.luau').read_text()
        code = learning[learning.index('do\n    local maxAliases'):]
        harness = harness.replace('-- __INSERT_LEARNING_CODE__', code).replace('-- __INSERT_RELOAD_CODE__', code)
        self.run_luau_text(harness.replace('-- __INSERT_AI_CODE__', norm + routing))

    def test_player_and_session_context(self):
        text = (ROOT / 'src/modules/30_overlay/148_cross_control.lua').read_text()
        norm = text[text.index('local function __askNorm'):text.index('local function __has')]
        routing = text[text.index('local __crossAskBase = Cross.ask'):text.index('\ndo\n    local previousExpand = Isl.expand')]
        self.run_luau('ai_context_harness.luau', '-- __INSERT_AI_CODE__', norm + routing)

    def test_registration(self):
        text = (ROOT / 'src/modules/40_window/210_el_discord.lua').read_text()
        registry = text[text.index('\t\t\t\t-- Register the library'):text.index('\t\t\t\treturn Tab')]
        self.run_luau('ai_registry_harness.luau', '-- __INSERT_REGISTRY_CODE__', registry)

if __name__ == '__main__':
    unittest.main()
