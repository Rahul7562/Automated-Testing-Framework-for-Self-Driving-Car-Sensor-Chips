def to_signed_32(val):
    val = val & 0xFFFFFFFF
    if val & 0x80000000:
        return val - 0x100000000
    return val

class EKFReferenceModel:
    def __init__(self):
        self.state_x = 0
        self.state_y = 0

    def step(self, meas_in):
        meas_x = to_signed_32(meas_in)
        meas_y = to_signed_32(meas_in >> 32)

        diff_x = to_signed_32(meas_x - self.state_x)
        diff_y = to_signed_32(meas_y - self.state_y)

        self.state_x = to_signed_32(self.state_x + (diff_x >> 1))
        self.state_y = to_signed_32(self.state_y + (diff_y >> 1))

        out_x = self.state_x & 0xFFFFFFFF
        out_y = self.state_y & 0xFFFFFFFF

        return (out_y << 32) | out_x
