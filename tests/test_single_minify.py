"""Offline tests for the single-line loader (set LUAU to a Luau CLI binary)."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'src'))
import minify

class SingleMinifyTests(unittest.TestCase):
    def test_single_line_reconstructs_and_forwards(self):
        luau = os.environ.get('LUAU')
        if not luau:
            self.skipTest('set LUAU to a Luau CLI executable')
        source = '''local greeting = "a\\nb"
local long = [==[
multiline "slash\\ x
last]==]
return greeting, long, ...
'''
        light = minify.minify(source, 'light')['code']
        wrapper = minify.minify(source, 'single')['code']
        self.assertNotIn('\n', wrapper)
        self.assertNotIn('\r', wrapper)
        with tempfile.TemporaryDirectory() as tmp:
            test = Path(tmp) / 'test.luau'
            # The expected value is independently compiled and compared at runtime.
            expected = minify._quote_piece(light)
            test.write_text('local expected=' + expected + '\n'
                            'local real=loadstring\nlocal loadstring=function(s) assert(s==expected); return assert(real(s)) end\n'
                            'local a,b,c=(function(...)\n' + wrapper + '\nend)(123)\n'
                            'assert(a=="a\\nb" and b=="multiline \\"slash\\\\ x\\nlast" and c==123)\n')
            subprocess.run([luau, str(test)], check=True)

if __name__ == '__main__':
    unittest.main()
