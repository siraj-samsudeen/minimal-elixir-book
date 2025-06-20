# prepare_book.exs
# Converts index.ipynb → index.qmd, cleans frontmatter, replaces common terms,
# quotes bare `iex` occurrences, and launches Quarto preview on fixed port.

defmodule BookPreview do
  def run do
    Process.flag(:trap_exit, true)

    convert()
    clean_and_replace()
    launch_quarto()
  end

  defp convert do
    input_file = "index.ipynb"

    {out, status} = System.cmd("quarto", ["convert", input_file])
    IO.puts("📦 Quarto convert output:")
    IO.write(out)

    if status != 0 do
      IO.puts("❌ Quarto convert failed.")
      System.halt(status)
    end
  end

  defp clean_and_replace do
    output_file = "index.qmd"

    {:ok, content} = File.read(output_file)

    content
    |> String.split("\n")
    |> remove_jupyter_frontmatter()
    |> replace_ai_terms()
    # |> quote_keywords(["iex", "ipython"])
    |> Enum.join("\n")
    |> then(&File.write!(output_file, &1))

    IO.puts("✅ Replaced content, cleaned frontmatter, and quoted `iex`.")
  end

  defp remove_jupyter_frontmatter(lines) do
    Enum.reject(lines, &(String.trim(&1) |> String.starts_with?("jupyter:")))
  end

  defp replace_ai_terms(lines) do
    lines
    |> Enum.map(&String.replace(&1, "AI Prompt", "Python Pro"))
    |> Enum.map(&String.replace(&1, "AI Response", "AI Elixir Mentor"))
  end

  # This function wraps bare (unquoted) occurrences of specific keywords
  # like `iex` and `ipython` in backticks, so they appear as inline code
  # in Markdown.
  #
  # Regex: ~r/(?<![`])\b(iex|ipython)\b(?![`])/
  # - (?<![`])    → Negative lookbehind: don't match if preceded by a backtick
  # - \b          → Word boundary
  # - (iex|ipython) → Match either "iex" or "ipython"
  # - \b          → Word boundary again (ensures whole word match)
  # - (?![`])     → Negative lookahead: don't match if followed by a backtick
  #
  # `\\1` in the replacement captures the matched word and surrounds it in backticks.

  defp quote_keywords(lines, words) do
    pattern = Enum.join(words, "|")  # "iex|ipython|mix" ...
    # iex> should NOT be replaced
    regex = ~r/(?<![`])\b(#{pattern})\b(?![`>\w])/

    Enum.map(lines, &Regex.replace(regex, &1, "`\\1`"))
  end

  defp launch_quarto do
    port = "3314"
    IO.puts("🚀 Launching preview on http://localhost:#{port}")

    spawn(fn ->
      System.cmd("quarto", ["preview", "--port", port],
        into: IO.stream(:stdio, :line),
        stderr_to_stdout: true
      )
    end)

    # Block main process forever — until user Ctrl+C
    Process.sleep(:infinity)
  end
end

BookPreview.run()
