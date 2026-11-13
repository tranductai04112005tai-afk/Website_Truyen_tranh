package TranDucTai.Tailuatruyen.service;

import TranDucTai.Tailuatruyen.entity.StatusEnum;
import TranDucTai.Tailuatruyen.entity.Story;
import TranDucTai.Tailuatruyen.repository.ChapterRepository;
import TranDucTai.Tailuatruyen.repository.StoryRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class StoryServiceTest {

    @Mock
    private StoryRepository storyRepository;

    @Mock
    private ChapterRepository chapterRepository;

    @InjectMocks
    private StoryService storyService;

    @Test
    void toggleVisibility_shouldKeepStoryInDatabase() {
        Story story = Story.builder().id(1L).title("Test story").status(StatusEnum.ACTIVE).build();
        when(storyRepository.findById(1L)).thenReturn(Optional.of(story));
        when(storyRepository.save(story)).thenReturn(story);

        Story updated = storyService.toggleVisibility(1L);

        assertEquals(StatusEnum.INACTIVE, updated.getStatus());
        assertEquals("Test story", updated.getTitle());
    }

    @Test
    void listAll_shouldIncludeHiddenStories() {
        Story active = Story.builder().id(1L).title("Visible").status(StatusEnum.ACTIVE).build();
        Story hidden = Story.builder().id(2L).title("Hidden").status(StatusEnum.INACTIVE).build();
        when(storyRepository.findAllByOrderByIdAsc()).thenReturn(List.of(active, hidden));

        List<Story> stories = storyService.listAll();

        assertEquals(2, stories.size());
        assertTrue(stories.stream().anyMatch(story -> story.getStatus() == StatusEnum.INACTIVE));
    }
}
