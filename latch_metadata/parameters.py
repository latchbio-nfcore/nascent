
from dataclasses import dataclass
import typing
import typing_extensions

from flytekit.core.annotation import FlyteAnnotation

from latch.types.metadata import NextflowParameter
from latch.types.file import LatchFile
from latch.types.directory import LatchDir, LatchOutputDir

# Import these into your `__init__.py` file:
#
# from .parameters import generated_parameters

generated_parameters = {
    'input': NextflowParameter(
        type=LatchFile,
        default=None,
        section_title='Input/output options',
        description='Path to comma-separated file containing information about the samples in the experiment.',
    ),
    'outdir': NextflowParameter(
        type=typing_extensions.Annotated[LatchDir, FlyteAnnotation({'output': True})],
        default=None,
        section_title=None,
        description='The output directory where the results will be saved. You have to use absolute paths to storage on Cloud infrastructure.',
    ),
    'email': NextflowParameter(
        type=typing.Optional[str],
        default=None,
        section_title=None,
        description='Email address for completion summary.',
    ),
    'multiqc_title': NextflowParameter(
        type=typing.Optional[str],
        default=None,
        section_title=None,
        description='MultiQC report title. Printed as page header, used for filename if not otherwise specified.',
    ),
    'aligner': NextflowParameter(
        type=typing.Optional[str],
        default='bwa',
        section_title='Alignment Options',
        description='Specify aligner to be used to map reads to reference genome.',
    ),
    'skip_alignment': NextflowParameter(
        type=typing.Optional[bool],
        default=None,
        section_title=None,
        description='Skip all of the alignment-based processes within the pipeline.',
    ),
    'skip_trimming': NextflowParameter(
        type=typing.Optional[bool],
        default=None,
        section_title=None,
        description='Skip the adapter trimming step.',
    ),
    'with_umi': NextflowParameter(
        type=typing.Optional[bool],
        default=None,
        section_title='UMI options',
        description='Enable UMI-based read deduplication.',
    ),
    'umitools_dedup_stats': NextflowParameter(
        type=typing.Optional[bool],
        default=None,
        section_title=None,
        description='Generate output stats when running "umi_tools dedup".',
    ),
    'assay_type': NextflowParameter(
        type=str,
        default=None,
        section_title='Transcript Identification Options',
        description='What type of nascent or TSS assay the sample is.',
    ),
    'skip_grohmm': NextflowParameter(
        type=typing.Optional[bool],
        default=None,
        section_title=None,
        description='Skip groHMM all together',
    ),
    'filter_bed': NextflowParameter(
        type=typing.Optional[str],
        default=None,
        section_title=None,
        description='Undesired regions, that transcripts should not overlap with',
    ),
    'intersect_bed': NextflowParameter(
        type=typing.Optional[str],
        default=None,
        section_title=None,
        description='Desired regions, that transcripts should overlap with',
    ),
    'genome': NextflowParameter(
        type=typing.Optional[str],
        default=None,
        section_title='Reference genome options',
        description='Name of iGenomes reference.',
    ),
    'fasta': NextflowParameter(
        type=typing.Optional[LatchFile],
        default=None,
        section_title=None,
        description='Path to FASTA genome file.',
    ),
    'gtf': NextflowParameter(
        type=typing.Optional[LatchFile],
        default=None,
        section_title=None,
        description='Path to GTF annotation file.',
    ),
    'gff': NextflowParameter(
        type=typing.Optional[LatchFile],
        default=None,
        section_title=None,
        description='Path to GFF3 annotation file.',
    ),
    'gene_bed': NextflowParameter(
        type=typing.Optional[LatchFile],
        default=None,
        section_title=None,
        description='Path to BED file containing gene intervals. This will be created from the GTF file if not specified.',
    ),
    'bwa_index': NextflowParameter(
        type=typing.Optional[str],
        default=None,
        section_title=None,
        description='Path to BWA mem indices.',
    ),
    'save_reference': NextflowParameter(
        type=typing.Optional[bool],
        default=None,
        section_title=None,
        description='If generated by the pipeline save the BWA index in the results directory.',
    ),
    'multiqc_methods_description': NextflowParameter(
        type=typing.Optional[str],
        default=None,
        section_title='Generic options',
        description='Custom MultiQC yaml file containing HTML including a methods description.',
    ),
}

