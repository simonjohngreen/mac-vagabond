#use a cloud image as we need cloud-init.
#vars
source config/variables.sh
ACVM.app/Contents/Resources/qemu-system-aarch64 \
  -M virt,highmem=off \
  -accel hvf \
  -cpu cortex-a72 \
  -smp $VMCORES,cores=$VMCORES \
  -m $VMMEMORY \
  -bios "./ACVM.app/Contents/Resources/QEMU_EFI.fd" \
  -device virtio-gpu-pci \
  -display default,show-cursor=on \
  -device qemu-xhci \
  -device usb-kbd \
  -device usb-tablet \
  -device intel-hda \
  -device hda-duplex \
  -net nic -net user,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:8080 \
  -drive file=disks/$VMIMAGEFILENAME,if=virtio \
  -drive file=disks/cidata.iso,if=virtio \
  -nographic
