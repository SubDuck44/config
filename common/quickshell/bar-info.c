#define _GNU_SOURCE

#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define die(...) err(1, __VA_ARGS__)
#define arrlen(arr) (sizeof(arr) / sizeof((arr)[0]))

#define FILES                                                                  \
	X(cpu, "/proc/stat")                                                       \
	X(mem, "/proc/meminfo")                                                    \
	X(batcap, "/sys/class/power_supply/BAT1/capacity")                         \
	X(batstat, "/sys/class/power_supply/BAT1/status")

int cpu_last_work  = 1;
int cpu_last_total = 1;

int rangeSum(const int* arr, size_t beg, size_t end) {
	int sum = 0;
	for(size_t i = beg; i <= end; i++) {
		sum += arr[i];
	}

	return sum;
}

int getValue(const char* buf, size_t len, const char* key) {
	char* beg = memmem(buf, len, key, strlen(key));
	strtok(beg, " ");               // Discard key
	return atoi(strtok(NULL, " ")); // Return value after key
}

int main(void) {
	setvbuf(stdout, NULL, _IOLBF, 0);

#define X(name, path)                                                          \
	int name##_file = open(path, O_RDONLY);                                    \
	if(name##_file < 0) die("Could not open " path);

	FILES

	char    buf[1024] = {0};
	ssize_t len       = 0;

#define READ(name)                                                             \
	do {                                                                       \
		lseek(name##_file, 0, SEEK_SET);                                       \
		len = read(name##_file, buf, sizeof(buf));                             \
		if(len < 0) die("Failed to read " #name);                              \
		buf[len - 1] = 0;                                                      \
	} while(0)

	for(;;) {
		READ(cpu);

		int cpu_vals[11] = {0};

		for(size_t i = 0; i < arrlen(cpu_vals); i++) {
			cpu_vals[i] = atoi(strtok(i == 0 ? buf : NULL, " \n"));
		}

		int    cpu_work  = rangeSum(cpu_vals, 1, 3);
		int    cpu_total = rangeSum(cpu_vals, 1, 10);
		double cpu_load =
			100.0 * (cpu_work - cpu_last_work) / (cpu_total - cpu_last_total);

		cpu_last_work  = cpu_work;
		cpu_last_total = cpu_total;

		////////////////////

		READ(mem);

		int mem_total   = getValue(buf, len, "MemTotal");
		int mem_free    = getValue(buf, len, "MemFree");
		int mem_buffer  = getValue(buf, len, "Buffers");
		int mem_cached  = getValue(buf, len, "Cached");
		int mem_reclaim = getValue(buf, len, "SReclaimable");

		/* fprintf( */
		/* 	stderr, "total: %d\nfree: %d\nbuf: %d\ncached: %d\nreclaim: %d\n",
		 */
		/* 	mem_total, mem_free, mem_buffer, mem_cached, mem_reclaim */
		/* ); */

		int mem_used =
			mem_total - mem_free - mem_buffer - mem_cached - mem_reclaim;

		////////////////////

		READ(batcap);

		int batcap = atoi(buf);

		////////////////////

		READ(batstat);

		const char* batstat = NULL;
		if(strncmp("Charging", buf, len) == 0)
			batstat = " ";
		else if(strncmp("Discharging", buf, len) == 0)
			batstat = " ";
		else
			batstat = " ";

		////////////////////

		printf(
			"%.1f%%\t%.2fG/%.2fG\t%d%%%s\n", //
			cpu_load,                        //
			mem_used / 1e6,                  //
			mem_total / 1e6,                 //
			batcap,                          //
			batstat                          //
		);

		sleep(1);
	}
}
