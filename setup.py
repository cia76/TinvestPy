from setuptools import setup, find_packages

setup(name='TinvestPy',
      version='1.42.2026.01.01',
      author='Чечет Игорь Александрович',
      description='Библиотека-обертка, которая позволяет работать с T-Invest API брокера Т-Инвестиции из Python',
      url='https://github.com/cia76/TinvestPy',
      packages=find_packages(),
      install_requires=[
            'keyring',  # Безопасное хранение торгового токена
            'grpcio',  # gRPC
            'protobuf',  # proto
            'googleapis-common-protos',  # Google API
            'types-protobuf',  # Timestamp
      ],
      python_requires='>=3.12',
      package_data={'TinvestPy': ['grpc/**/*']},  # Дополнительно копируем скрипты из папки grpc и вложенных в нее папок
      include_package_data=True,  # Включаем дополнительные скрипты
      )
