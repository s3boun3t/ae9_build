/* AE-9 ACM I2C register offsets on BAR2 */
#define AE9_I2C_CMD    0xc00
#define AE9_I2C_DATA   0xc04
#define AE9_I2C_FIFO   0xc08
#define AE9_I2C_STATUS 0xc0c

static void ae9_i2c_send(struct hda_codec *codec,
			  const unsigned int *data, int len)
{
	struct ca0132_spec *spec = codec->spec;
	int i;
	writel(0xf0, spec->mem_base + AE9_I2C_CMD);
	for (i = 0; i < len; i++)
		writel(data[i], spec->mem_base + AE9_I2C_CMD);
	writel(0xf7, spec->mem_base + AE9_I2C_CMD);
}

static int ae9_acm_init(struct hda_codec *codec)
{
	struct ca0132_spec *spec = codec->spec;
	unsigned int status, fifo;
	static const unsigned int hs_fwd[] = {0x54,0x04,0x41,0x63,0x6d,0x31};
	static const unsigned int hs_rev[] = {0x54,0x04,0x31,0x6d,0x63,0x41};
	static const unsigned int cfg[] = {0xd5,0x03,0x00,0x20,0x04};
	static const unsigned int stchk[] = {0x54,0x04,0x11,0x11,0x11,0x11};
	static const unsigned int key[] = {0x55,0x07,0x00,0x20,0x04,0xde,0xc0,0xad,0xde};
	static const unsigned int reset[] = {0x81,0x00};
	static const unsigned int gpio1[] = {0x03,0x03,0x05,0x03,0x03};
	static const unsigned int sr48[] = {0x32,0x03,0x02,0xb8,0x0b};
	static const unsigned int vol[] = {0x43,0x04,0x64,0x00,0xf4,0x01};
	static const unsigned int sr96[] = {0x32,0x03,0x01,0x88,0x13};
	static const unsigned int ch[] = {0x05,0x03,0x02,0x01,0x00};
	static const unsigned int unmute1[] = {0x22,0x02,0x01,0x00};
	static const unsigned int mute2[] = {0x22,0x02,0x02,0x01};
	static const unsigned int gpio2[] = {0x03,0x03,0x02,0x00,0x40};
	static const unsigned int name[] = {0x11,0x09,0x41,0x45,0x2d,0x39,0x00,0x00,0x00,0x00,0x00};
	static const unsigned int pwr[] = {0x21,0x03,0x02,0x00,0x00};
	static const unsigned int out1[] = {0x83,0x01,0x02};
	static const unsigned int out2[] = {0x83,0x01,0x07};
	static const unsigned int query[] = {0xc2,0x00};
	static const unsigned int insel[] = {0x85,0x01,0x02};
	static const unsigned int dac1[] = {0xb1,0x01,0x01};
	static const unsigned int dac2[] = {0xb1,0x01,0x02};
	static const unsigned int dac3[] = {0xb1,0x01,0x03};

	if (!spec->mem_base) return -ENODEV;
	codec_info(codec, "AE-9: Starting ACM initialization\n");

	/* Phase 1: I2C bus init */
	status = readl(spec->mem_base + AE9_I2C_STATUS);
	codec_dbg(codec, "AE-9 I2C status: 0x%08x\n", status);
	writel(0x30, spec->mem_base + AE9_I2C_CMD);
	writel(0x00, spec->mem_base + AE9_I2C_DATA);
	usleep_range(5000, 10000);
	status = readl(spec->mem_base + AE9_I2C_STATUS);
	fifo = readl(spec->mem_base + AE9_I2C_FIFO);
	codec_dbg(codec, "AE-9 FIFO: 0x%08x status: 0x%08x\n", fifo, status);
	fifo = readl(spec->mem_base + AE9_I2C_FIFO);
	fifo = readl(spec->mem_base + AE9_I2C_FIFO);
	fifo = readl(spec->mem_base + AE9_I2C_FIFO);
	fifo = readl(spec->mem_base + AE9_I2C_FIFO);
	writel(0x80, spec->mem_base + AE9_I2C_DATA);
	writel(0x0d, spec->mem_base + AE9_I2C_CMD);
	writel(0x00, spec->mem_base + AE9_I2C_DATA);
	usleep_range(2000, 5000);

	/* Phase 2: Reset + Handshake + Key */
	ae9_i2c_send(codec, reset, 2);
	usleep_range(2000, 5000);
	ae9_i2c_send(codec, hs_fwd, 6);
	ae9_i2c_send(codec, hs_rev, 6);
	ae9_i2c_send(codec, cfg, 5);
	ae9_i2c_send(codec, stchk, 6);
	ae9_i2c_send(codec, hs_fwd, 6);
	ae9_i2c_send(codec, hs_rev, 6);
	ae9_i2c_send(codec, key, 9);
	ae9_i2c_send(codec, stchk, 6);
	usleep_range(5000, 10000);

	/* Phase 3: Audio config */
	ae9_i2c_send(codec, gpio1, 5);
	ae9_i2c_send(codec, sr48, 5);
	ae9_i2c_send(codec, vol, 6);
	ae9_i2c_send(codec, sr96, 5);
	ae9_i2c_send(codec, ch, 5);
	ae9_i2c_send(codec, unmute1, 4);
	ae9_i2c_send(codec, mute2, 4);
	ae9_i2c_send(codec, gpio2, 5);

	/* Phase 4: Identification + Output routing */
	ae9_i2c_send(codec, name, 11);
	ae9_i2c_send(codec, pwr, 5);
	ae9_i2c_send(codec, out1, 3);
	ae9_i2c_send(codec, out2, 3);
	ae9_i2c_send(codec, reset, 2);
	usleep_range(2000, 5000);
	ae9_i2c_send(codec, hs_fwd, 6);
	ae9_i2c_send(codec, hs_rev, 6);
	ae9_i2c_send(codec, cfg, 5);
	ae9_i2c_send(codec, stchk, 6);
	ae9_i2c_send(codec, query, 2);
	ae9_i2c_send(codec, insel, 3);
	ae9_i2c_send(codec, dac1, 3);
	ae9_i2c_send(codec, dac2, 3);
	ae9_i2c_send(codec, dac3, 3);

	codec_info(codec, "AE-9: ACM initialization complete\n");
	return 0;
}
