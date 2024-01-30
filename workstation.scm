(define-module (workstation)
  #:use-module (gnu)
  #:use-module (gnu system nss)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages tmux)
  #:use-module (gnu services networking)
  #:use-module (gnu services ssh))

(operating-system
  (host-name "Workstation")
  (timezone "Asia/Shanghai")
  (locale "en_US.UTF-8")
  (initrd-modules (append (list "mptspi")
			  %base-initrd-modules))
  (bootloader (bootloader-configuration
	       (bootloader grub-efi-bootloader)
	       (targets '("/boot/efi"))))
  (file-systems (cons* (file-system
			 (device (file-system-label "root"))
			 (mount-point "/")
			 (type "btrfs"))
		       (file-system
			 (device (file-system-label "EFI"))
			 (mount-point "/boot/efi")
			 (type "vfat"))
		       (file-system
			 (device (file-system-label "home"))
			 (mount-point "/home")
			 (type "btrfs"))
		       %base-file-systems))
  (swap-devices (list
		 (swap-space (target (file-system-label "swap")))))
  (users (cons (user-account
		(name "c4droid")
		(comment "c4droid")
		(group "users")
		(shell (file-append zsh "/bin/zsh"))
		(supplementary-groups '("wheel" "audio" "video" "netdev")))
	       %base-user-accounts))
  (packages (cons* emacs-no-x emacs-guix git tmux nss-certs %base-packages))
  (services (append (list (service dhcp-client-service-type)
			  (service ntp-service-type)
			  (service openssh-service-type
				   (openssh-configuration
				    (openssh openssh-sans-x))))
		    (modify-services %base-services
		      (guix-service-type config => (guix-configuration
						    (inherit config)
						    (substitute-urls '("https://mirror.sjtu.edu.cn/guix")))))))
  (name-service-switch %mdns-host-lookup-nss))
