CC = gcc
CFLAGS = -Wall -Werror -std=c11
LDFLAGS =

SRCS = main.c
OBJS = $(SRCS:.c=.o)
TARGET = program

CLEAN = rm -f $(OBJS)
CLEANALL = rm -f $(OBJS) $(TARGET)

clean:
	$(CLEAN)

cleanall:
	$(CLEANALL)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -o $(TARGET)
	$(CLEAN)

main.o: main.c header.h stdlib.h
	$(CC) $(CFLAGS) -c main.c
