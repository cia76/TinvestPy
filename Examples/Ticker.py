import logging  # Выводим лог на консоль и в файл
from datetime import date, timedelta, datetime  # Дата и время
from math import log10

from TinvestPy import TinvestPy  # Работа с T-Invest API из Python


def get_future_on_date(base, future_date=date.today()):  # Фьючерсный контракт на дату
    if future_date.day > 15 and future_date.month in (3, 6, 9, 12):  # Если нужно переходить на следующий фьючерс
        future_date += timedelta(days=30)  # то добавляем месяц к дате
    period = 'H' if future_date.month <= 3 else 'M' if future_date.month <= 6 else 'U' if future_date.month <= 9 else 'Z'  # Месяц экспирации: 3-H, 6-M, 9-U, 12-Z
    digit = future_date.year % 10  # Последняя цифра года
    return f'SPBFUT.{base}{period}{digit}'


if __name__ == '__main__':  # Точка входа при запуске этого скрипта
    logger = logging.getLogger('TinvestPy.Ticker')  # Будем вести лог
    tp_provider = TinvestPy()  # Подключаемся к торговому счету

    logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',  # Формат сообщения
                        datefmt='%d.%m.%Y %H:%M:%S',  # Формат даты
                        level=logging.INFO,  # Уровень логируемых событий NOTSET/DEBUG/INFO/WARNING/ERROR/CRITICAL
                        handlers=[logging.FileHandler('Ticker.log', encoding='utf-8'), logging.StreamHandler()])  # Лог записываем в файл и выводим на консоль
    logging.Formatter.converter = lambda *args: datetime.now(tz=tp_provider.tz_msk).timetuple()  # В логе время указываем по МСК

    datanames = ('TQBR.SBER', 'TQBR.HYDR', get_future_on_date("Si"), get_future_on_date("RI"), 'SPBFUT.CNYRUBF', 'SPBFUT.IMOEXF')  # Кортеж тикеров

    for dataname in datanames:  # Пробегаемся по всем тикерам
        class_code, security_code = tp_provider.dataname_to_class_code_symbol(dataname)  # Код режима торгов и тикер
        si = tp_provider.get_symbol_info(class_code, security_code)
        if not si:  # Если тикер не найден
            logger.warning(f'Тикер {class_code}.{security_code} не найден')
            continue  # то переходим к следующему тикеру, дальше не продолжаем
        logger.info(f'Ответ от сервера: {si}')
        logger.info(f'Информация о тикере {si.class_code}.{si.ticker} ({si.name}, {si.exchange})')
        logger.info(f'- Валюта: {si.currency}')
        logger.info(f'- Лот: {si.lot}')
        min_step = tp_provider.quotation_to_float(si.min_price_increment)  # Шаг цены
        logger.info(f'- Шаг цены: {min_step}')
        decimals = int(log10(1 / min_step) + 0.99)  # Из шага цены получаем кол-во десятичных знаков
        logger.info(f'- Кол-во десятичных знаков: {decimals}')

    tp_provider.close_channel()  # Закрываем канал перед выходом
