import logging  # Выводим лог на консоль и в файл
from datetime import datetime  # Дата и время
from threading import Thread  # Запускаем поток подписки

from TinvestPy import TinvestPy  # Работа с T-Invest API из Python
from TinvestPy.grpc.marketdata_pb2 import MarketDataRequest, SubscribeCandlesRequest, SubscriptionAction, CandleInstrument, SubscriptionInterval, Candle


def on_new_bar(candle: Candle):  # Обработчик события прихода нового бара
    logger.info(f'{tp_provider.google_timestamp_to_msk_datetime(candle.time):%d.%m.%Y %H:%M:%S} '
                f'O: {tp_provider.quotation_to_float(candle.open)} '
                f'H: {tp_provider.quotation_to_float(candle.high)} '
                f'L: {tp_provider.quotation_to_float(candle.low)} '
                f'C: {tp_provider.quotation_to_float(candle.close)} '
                f'V: {int(candle.volume)}')


if __name__ == '__main__':  # Точка входа при запуске этого скрипта
    logger = logging.getLogger('TinvestPy.Connect')  # Будем вести лог
    # tp_provider = TinvestPy('<Токен>')  # При первом подключении нужно передать токен
    tp_provider = TinvestPy()  # Подключаемся ко всем торговым счетам

    logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',  # Формат сообщения
                        datefmt='%d.%m.%Y %H:%M:%S',  # Формат даты
                        level=logging.INFO,  # Уровень логируемых событий NOTSET/DEBUG/INFO/WARNING/ERROR/CRITICAL
                        handlers=[logging.FileHandler('Connect.log', encoding='utf-8'), logging.StreamHandler()])  # Лог записываем в файл и выводим на консоль
    logging.Formatter.converter = lambda *args: datetime.now(tz=tp_provider.tz_msk).timetuple()  # В логе время указываем по МСК

    dataname = 'TQBR.SBER'  # Тикер
    tf = 'M1'  # Временной интервал

    # Проверяем работу запрос/ответ
    logger.info(f'Данные тикера {dataname}')  # Время на сервере приходит в подписках. Поэтому, запросим данные тикера
    class_code, symbol = tp_provider.dataname_to_class_code_symbol(dataname)
    si = tp_provider.get_symbol_info(class_code, symbol)  # Спецификация тикера
    logger.info(f'Ответ от сервера: {si}' if si else f'Тикер {dataname} не найден')

    # Проверяем работу подписок
    logger.info(f'Подписка на {tf} бары тикера {dataname}')
    tp_provider.on_candle.subscribe(on_new_bar)  # Подписываемся на новые бары
    Thread(target=tp_provider.subscriptions_marketdata_handler, name='SubscriptionsMarketdataThread').start()  # Создаем и запускаем поток обработки подписок сделок по заявке
    tp_provider.subscription_marketdata_queue.put(  # Ставим в буфер команд подписки на биржевую информацию
        MarketDataRequest(subscribe_candles_request=SubscribeCandlesRequest(  # запрос на новые бары
            subscription_action=SubscriptionAction.SUBSCRIPTION_ACTION_SUBSCRIBE,  # подписка
            instruments=(CandleInstrument(interval=SubscriptionInterval.SUBSCRIPTION_INTERVAL_ONE_MINUTE, instrument_id=si.figi),),  # на тикер по временному интервалу 1 минута
            waiting_close=True)))  # по закрытию бара

    # Выход
    input('Enter - выход\n')
    tp_provider.on_candle.unsubscribe(on_new_bar)  # Отменяем подписку на новые бары
    tp_provider.close_channel()  # Закрываем канал перед выходом
