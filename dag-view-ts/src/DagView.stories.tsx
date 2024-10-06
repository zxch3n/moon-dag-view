import { Meta, StoryFn } from '@storybook/react';
import { DagViewComponent, ViewDagNode } from './DagView';

export default {
    title: 'Components/DagView',
    component: DagViewComponent,
} as Meta;

const Template: StoryFn<{ nodes: ViewDagNode[], frontiers: string[] }> = (args) => <DagViewComponent {...args} />;

export const Basic = Template.bind({});
Basic.args = {
    nodes: [
        { id: '1', deps: [], lamport: 1, message: "feat: Hello", author: "Alice" },
        { id: '2', deps: ['1'], lamport: 2, message: "fix: Bug in feature", author: "Bob" },
        { id: '3', deps: ['1'], lamport: 3, message: "docs: Update README", author: "Charlie" },
        { id: '4', deps: ['2', '3'], lamport: 4, message: "refactor: Improve code structure", author: "David" },
    ],
    frontiers: ['4'],
};

export const ComplexDag = Template.bind({});
ComplexDag.args = {
    nodes: [
        { id: 'A', deps: [], lamport: 1, message: "feat: Initial commit", author: "Alice" },
        { id: 'B', deps: ['A'], lamport: 2, message: "feat: Add user authentication", author: "Bob" },
        { id: 'C', deps: ['A'], lamport: 3, message: "fix: Handle edge case in login", author: "Charlie" },
        { id: 'D', deps: ['B'], lamport: 4, message: "feat: Implement user profile", author: "David" },
        { id: 'E', deps: ['B', 'C'], lamport: 5, message: "refactor: Optimize database queries", author: "Eve" },
        { id: 'F', deps: ['D', 'E'], lamport: 6, message: "feat: Add social sharing functionality", author: "Frank" },
    ],
    frontiers: ['F'],
};

export const MultipleFrontiers = Template.bind({});
MultipleFrontiers.args = {
    nodes: [
        { id: 'X', deps: [], lamport: 1, message: "feat: Create project structure", author: "Xavier" },
        { id: 'Y', deps: ['X'], lamport: 2, message: "feat: Implement feature A", author: "Yves" },
        { id: 'Z', deps: ['X'], lamport: 3, message: "feat: Implement feature B", author: "Zoe" },
    ],
    frontiers: ['Y', 'Z'],
};

export const ComplexMergeScenario = Template.bind({});
ComplexMergeScenario.args = {
    nodes: [
        { id: 'A', deps: [], lamport: 1, message: "feat: Initial project setup", author: "Alice" },
        { id: 'B', deps: ['A'], lamport: 2, message: "feat: Implement user authentication", author: "Bob" },
        { id: 'C', deps: ['B'], lamport: 3, message: "fix: Resolve login edge case", author: "Charlie" },
        { id: 'D', deps: ['A'], lamport: 4, message: "feat: Add product catalog", author: "David" },
        { id: 'E', deps: ['D'], lamport: 5, message: "feat: Implement search functionality", author: "Eve" },
        { id: 'F', deps: ['C', 'E'], lamport: 6, message: "feat: Integrate user profiles with product recommendations", author: "Frank" },
        { id: 'G', deps: ['C'], lamport: 7, message: "feat: Add two-factor authentication", author: "Grace" },
        { id: 'H', deps: ['E'], lamport: 8, message: "fix: Optimize search algorithm", author: "Henry" },
        { id: 'I', deps: ['F', 'G'], lamport: 9, message: "feat: Implement social sharing", author: "Ivy" },
        { id: 'J', deps: ['H'], lamport: 10, message: "feat: Add advanced filtering options", author: "Jack" },
        { id: 'K', deps: ['I', 'J'], lamport: 11, message: "feat: Create personalized user dashboard", author: "Kate" },
        { id: 'L', deps: ['G'], lamport: 12, message: "fix: Address security vulnerability in authentication", author: "Liam" },
        { id: 'M', deps: ['J'], lamport: 13, message: "feat: Implement real-time product updates", author: "Mia" },
        { id: 'N', deps: ['K', 'L', 'M'], lamport: 14, message: "feat: Add AI-powered recommendations", author: "Noah" },
        { id: 'O', deps: ['N'], lamport: 15, message: "fix: Resolve conflicts in merged features", author: "Olivia" },
        { id: 'P', deps: ['O'], lamport: 16, message: "feat: Implement A/B testing framework", author: "Paul" },
        { id: 'Q', deps: ['P'], lamport: 17, message: "feat: Add multi-language support", author: "Quinn" },
        { id: 'R', deps: ['M'], lamport: 18, message: "feat: Implement inventory management system", author: "Rachel" },
        { id: 'S', deps: ['Q', 'R'], lamport: 19, message: "feat: Create advanced analytics dashboard", author: "Sam" },
        { id: 'T', deps: ['S'], lamport: 20, message: "fix: Optimize database queries for improved performance", author: "Tom" },
    ],
    frontiers: ['T', 'P'],
};

export const ConflictingBranches = Template.bind({});
ConflictingBranches.args = {
    nodes: [
        { id: 'Root', deps: [], lamport: 1, message: "feat: Initial commit", author: "Team" },
        { id: 'A1', deps: ['Root'], lamport: 2, message: "feat: Implement feature X (approach 1)", author: "Alice" },
        { id: 'A2', deps: ['A1'], lamport: 3, message: "fix: Bug in feature X implementation", author: "Alice" },
        { id: 'A3', deps: ['A2'], lamport: 4, message: "feat: Extend feature X functionality", author: "Alice" },
        { id: 'B1', deps: ['Root'], lamport: 2, message: "feat: Implement feature X (approach 2)", author: "Bob" },
        { id: 'B2', deps: ['B1'], lamport: 3, message: "test: Add tests for feature X", author: "Bob" },
        { id: 'B3', deps: ['B2'], lamport: 4, message: "refactor: Optimize feature X implementation", author: "Bob" },
        { id: 'C1', deps: ['Root'], lamport: 2, message: "feat: Implement feature Y", author: "Charlie" },
        { id: 'C2', deps: ['C1'], lamport: 3, message: "fix: Edge case in feature Y", author: "Charlie" },
        { id: 'M1', deps: ['A3', 'B3', 'C2'], lamport: 5, message: "merge: Resolve conflicts and merge all branches", author: "David" },
        { id: 'M2', deps: ['M1'], lamport: 6, message: "fix: Address issues from merge", author: "David" },
        { id: 'E1', deps: ['M2'], lamport: 7, message: "feat: Implement feature Z", author: "Eve" },
        { id: 'F1', deps: ['M2'], lamport: 7, message: "refactor: Codebase cleanup", author: "Frank" },
        { id: 'G1', deps: ['E1', 'F1'], lamport: 8, message: "feat: Integrate features X, Y, and Z", author: "Grace" },
    ],
    frontiers: ['G1'],
};

export const ConflictingBranches2 = Template.bind({});
ConflictingBranches2.args = {
    nodes: [
        { id: 'Root', deps: [], lamport: 1, message: "feat: Initial commit", author: "Team" },
        { id: 'A1', deps: [], lamport: 2, message: "feat: Implement feature X (approach 1)", author: "Alice" },
        { id: 'A2', deps: [], lamport: 3, message: "fix: Bug in feature X implementation", author: "Alice" },
        { id: 'A3', deps: [], lamport: 4, message: "feat: Extend feature X functionality", author: "Alice" },
        { id: 'B1', deps: ['A1', 'A2', 'A3'], lamport: 2, message: "feat: Implement feature X (approach 2)", author: "Bob" },
        { id: 'B2', deps: ['A1', 'A2', 'A3'], lamport: 3, message: "test: Add tests for feature X", author: "Bob" },
        { id: 'B3', deps: ['A1', 'A2', 'A3'], lamport: 4, message: "refactor: Optimize feature X implementation", author: "Bob" },
        { id: 'C1', deps: ['Root'], lamport: 2, message: "feat: Implement feature Y", author: "Charlie" },
        { id: 'C2', deps: ['C1'], lamport: 3, message: "fix: Edge case in feature Y", author: "Charlie" },
        { id: 'M1', deps: ['A3', 'B3', 'C2'], lamport: 5, message: "merge: Resolve conflicts and merge all branches", author: "David" },
        { id: 'M2', deps: ['M1'], lamport: 6, message: "fix: Address issues from merge", author: "David" },
        { id: 'E1', deps: ['M2'], lamport: 7, message: "feat: Implement feature Z", author: "Eve" },
        { id: 'F1', deps: ['M2'], lamport: 7, message: "refactor: Codebase cleanup", author: "Frank" },
        { id: 'G1', deps: ['E1', 'F1'], lamport: 8, message: "feat: Integrate features X, Y, and Z", author: "Grace" },
    ],
    frontiers: ['G1'],
};
