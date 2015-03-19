import java.io.File;
import java.io.BufferedReader;
import java.io.Reader;
import java.io.IOException;

import java.util.Formatter;

import org.jacoco.core.analysis.Analyzer;
import org.jacoco.core.analysis.CoverageBuilder;
import org.jacoco.core.analysis.IBundleCoverage;
import org.jacoco.core.analysis.IPackageCoverage;
import org.jacoco.core.analysis.ISourceFileCoverage;
import org.jacoco.core.analysis.ICounter;
import org.jacoco.core.tools.ExecFileLoader;
import org.jacoco.report.ISourceFileLocator;
import org.jacoco.report.DirectorySourceFileLocator;

/**
 * Creates a simple textual report of uncovered lines of code and writes this
 * report to standard output. Execution data is taken from a single jacoco.exec
 * file, classes are assumed to be in a bin directory, and source is assumed to
 * be in the current directory.
 */
public class ReportGenerator {

	private final String title;

	private final File executionDataFile;
	private final File classesDirectory;
	private final File sourceDirectory;

	private ExecFileLoader execFileLoader;

	/**
	 * Create a new generator based for the given project.
	 */
	public ReportGenerator(final File projectDirectory) {
		this.title = projectDirectory.getName();
		this.executionDataFile = new File(projectDirectory, "jacoco.exec");
		this.classesDirectory = new File(projectDirectory, "bin");
		this.sourceDirectory = projectDirectory;
	}

	/**
	 * Create the report.
	 * 
	 * @throws IOException
	 */
	public void create() throws IOException {
		loadExecutionData();
		createReport(analyzeStructure());
	}

	private void createReport(final IBundleCoverage bundleCoverage)
			throws IOException {
		ICounter counter = bundleCoverage.getLineCounter();

		StringBuilder builder = new StringBuilder();
		Formatter formatter = new Formatter(builder);
		formatter.format("%d of %d executable lines are not tested (%d%% coverage)%n%n",
			counter.getMissedCount(), counter.getTotalCount(), (int)(counter.getCoveredRatio() * 100));

		ISourceFileLocator locator = new DirectorySourceFileLocator(sourceDirectory, "utf-8", 4);

		for (IPackageCoverage packageCoverage : bundleCoverage.getPackages()) {
			for (ISourceFileCoverage coverage : packageCoverage.getSourceFiles()) {
				counter = coverage.getLineCounter();

				if (counter.getMissedCount() > 0) {
					formatter.format("%d %s not tested in %s%n", counter.getMissedCount(), counter.getMissedCount() == 1 ? "line is" : "lines are", coverage.getName());

					final Reader reader = locator.getSourceFile(coverage.getPackageName(), coverage.getName());

					if (reader == null) {
						formatter.format("Source file could not be read%n%n");
						continue;
					} else
						formatter.format("%n");

					final BufferedReader lineBuffer = new BufferedReader(reader);
					String line;
					int nr = 0;
					while ((line = lineBuffer.readLine()) != null) {
						nr++;
						int status = coverage.getLine(nr).getStatus();
						if (status == ICounter.NOT_COVERED)
							formatter.format("%3d\t%s%n", nr, line);
					}

					formatter.format("%n");
				}
			}
		}

		System.out.print(formatter);
	}

	private void loadExecutionData() throws IOException {
		execFileLoader = new ExecFileLoader();
		execFileLoader.load(executionDataFile);
	}

	private IBundleCoverage analyzeStructure() throws IOException {
		final CoverageBuilder coverageBuilder = new CoverageBuilder();
		final Analyzer analyzer = new Analyzer(
				execFileLoader.getExecutionDataStore(), coverageBuilder);
		analyzer.analyzeAll(classesDirectory);
		return coverageBuilder.getBundle(title);
	}

	/**
	 * Starts the report generation process
	 * 
	 * @param args command line arguments, currently unused
	 * @throws IOException
	 */
	public static void main(final String[] args) throws IOException {
		final ReportGenerator generator = new ReportGenerator(new File("."));
		generator.create();
	}
}
