class Dock:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.name = config.get_name().split(' ')[-1]
        self.location = config.get('location')
        self.safe_y = float(config.get('safe_y') or 0)
        self.safe_zd = float(config.get('safe_zd') or 0)
        self.load_yd = float(config.get('load_yd') or 0)
        self.load_xd = float(config.get('load_xd') or 0)
        self.align_speed = float(config.get('align_speed')) * 60
        self.loading_speed = float(config.get('loading_speed')) * 60
        self.loading_pause = config.get('loading_pause') or 1
        self.printer.add_object('dock ' + self.name, self)


def load_config_prefix(config):
    return Dock(config)
