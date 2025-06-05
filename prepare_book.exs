# prepare_book.exs

# Step 1: Run quarto convert via system call (super minimal form)
{output, exit_status} = System.cmd("quarto", ["convert", "index.ipynb"])

IO.puts(output)

if exit_status != 0 do
  IO.puts("❌ quarto convert failed!")
  System.halt(exit_status)
end

# Step 2: Clean up frontmatter (remove jupyter:)
filename = "index.qmd"

{:ok, content} = File.read(filename)
lines = String.split(content, "\n")

cleaned_lines =
  lines
  |> Enum.reject(fn line -> String.trim(line) |> String.starts_with?("jupyter:") end)

File.write!(filename, Enum.join(cleaned_lines, "\n"))

IO.puts("✅ Conversion and cleanup complete!")
