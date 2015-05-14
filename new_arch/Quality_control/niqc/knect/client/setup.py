from setuptools import setup


def readme():
    with open('README.rst') as f:
        return f.read()
    
    
setup(name='knect',
      version='0.1',
      description='KNECT Python Package',
      url='http://github.com/UCSFMemoryAndAging/knect',
      author='Joe Hesse',
      author_email='joe.hesse@ucsf.edu',
      license='',
      packages=['knect'],
      install_requires=[
          'ply,jsonschema,json',
      ],
      zip_safe=False)