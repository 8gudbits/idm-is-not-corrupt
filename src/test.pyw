import tkinter as tk

root = tk.Tk()
root.title("IDM is corrupt")

root.geometry("300x100")
label = tk.Label(root, text="Test window for IDM watchdog")
label.pack(expand=True)
root.mainloop()
