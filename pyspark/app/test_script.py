import unittest
from main import is_odd


class TestIsOdd(unittest.TestCase):
    def test_three(self):
        self.assertTrue(is_odd(3))

    def test_four(self):
        self.assertFalse(is_odd(4))

    def test_five(self):
        self.assertTrue(is_odd(5))

    def test_ten(self):
        self.assertFalse(is_odd(10))


if __name__ == "__main__":
    unittest.main()
