from setuptools import setup

setup(name='TinvestPy',
      version='1.42',
      author='Чечет Игорь Александрович',
      description='Библиотека-обертка, которая позволяет работать с T-Invest API брокера Т-Инвестиции из Python',
      url='https://github.com/cia76/TinvestPy',
      packages=['TinvestPy'],
      install_requires=[
            'pytz',  # ВременнЫе зоны
            'grpcio',  # gRPC
            'protobuf',  # proto
            'googleapis-common-protos',  # Google API
            'types-protobuf',  # Timestamp
      ],
      python_requires='>=3.12',
      package_data={'TinvestPy': ['grpc/**/*']},  # Дополнительно копируем скрипты из папки grpc и вложенных в нее папок
      include_package_data=True,  # Включаем дополнительные скрипты
      )
