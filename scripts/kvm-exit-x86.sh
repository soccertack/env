

PREFIX="/sys/kernel/debug/kvm/"

P_EXITS=$(sudo cat $PREFIX/exits)
P_IO=$(sudo cat $PREFIX/io_exits)
P_IRQ=$(sudo cat $PREFIX/irq_exits)
P_HALT=$(sudo cat $PREFIX/halt_exits)
P_MMIO=$(sudo cat $PREFIX/mmio_exits)
echo -n "Press any key to print diff and reset"
read number
N_EXITS=$(sudo cat $PREFIX/exits)
N_IO=$(sudo cat $PREFIX/io_exits)
N_IRQ=$(sudo cat $PREFIX/irq_exits)
N_HALT=$(sudo cat $PREFIX/halt_exits)
N_MMIO=$(sudo cat $PREFIX/mmio_exits)

DF_EXITS=$((N_EXITS - P_EXITS))
DF_IO=$((N_IO - P_IO))
DF_IRQ=$((N_IRQ - P_IRQ))
DF_HALT=$((N_HALT - P_HALT))
DF_MMIO=$((N_MMIO - P_MMIO))
echo "exits: $DF_EXITS"
echo "io exits: $DF_IO"
echo "irq exits: $DF_IRQ"
echo "halt: $DF_HALT"
echo "mmio: $DF_MMIO"

